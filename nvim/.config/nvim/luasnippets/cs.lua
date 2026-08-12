local ls = require('luasnip')
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local d = ls.dynamic_node
local sn = ls.snippet_node
local rep = require('luasnip.extras').rep

local function roslyn_attached()
    return #vim.lsp.get_clients({ bufnr = 0, name = 'roslyn_ls' }) > 0
end

local roslyn_only = {
    condition = roslyn_attached,
    show_condition = roslyn_attached,
}

local FN_NODE_TYPES = {
    method_declaration = true,
    constructor_declaration = true,
    local_function_statement = true,
}

-- First function-like node starting at or below the given 0-based row.
local function next_function_below(row0)
    local ok, parser = pcall(vim.treesitter.get_parser, 0)
    if not ok or not parser then return nil end
    local tree = parser:parse()[1]
    if not tree then return nil end

    local best, best_row
    local function visit(node)
        for child in node:iter_children() do
            if child:named() then
                local srow, _, erow = child:range()
                if FN_NODE_TYPES[child:type()] and srow >= row0 and (not best_row or srow < best_row) then
                    best, best_row = child, srow
                end
                if erow >= row0 then visit(child) end
            end
        end
    end
    visit(tree:root())
    return best
end

-- Text of T when the given subtree contains [Api.]IResult<T>, else nil.
local function find_iresult_type(node, buf)
    local stack = { node }
    while #stack > 0 do
        local n = table.remove(stack)
        if n:type() == 'generic_name' then
            local name = n:named_child(0)
            local args = n:named_child(1)
            if name and args and vim.treesitter.get_node_text(name, buf) == 'IResult' then
                local text = vim.treesitter.get_node_text(args, buf)
                return (text:gsub('^<', ''):gsub('>$', ''):gsub('%s+', ' '))
            end
        end
        for c in n:iter_children() do
            if c:named() then stack[#stack + 1] = c end
        end
    end
end

-- T of the Api.IResult<T> returned by the function enclosing the cursor,
-- nil when the enclosing function returns something else.
-- Reparses explicitly: the highlighter's tree can be stale mid-edit.
local function enclosing_iresult_type()
    local ok, T = pcall(function()
        local parser = vim.treesitter.get_parser(0)
        if not parser then return nil end
        local tree = parser:parse()[1]
        if not tree then return nil end
        local pos = vim.api.nvim_win_get_cursor(0)
        local row = pos[1] - 1
        local node = tree:root():named_descendant_for_range(row, pos[2], row, pos[2])
        while node do
            local nt = node:type()
            if nt == 'method_declaration' or nt == 'local_function_statement' then
                -- a function node starting on the cursor row is the half-typed
                -- fragment itself (error recovery artifact), not the enclosing
                -- function: keep walking up
                local srow = node:range()
                if srow ~= row then
                    local ret = node:field('returns')[1]
                    return ret and find_iresult_type(ret, 0) or nil
                end
            end
            node = node:parent()
        end
    end)
    if not ok then return nil end
    return T
end

local function in_iresult_function()
    return roslyn_attached() and enclosing_iresult_type() ~= nil
end

local iresult_only = {
    condition = in_iresult_function,
    show_condition = in_iresult_function,
}

-- Variable tested with `.Success` in the condition of an if statement
-- enclosing the cursor, nil when there is no such if.
-- Treesitter first; while the trigger word is being half-typed, error
-- recovery drops the enclosing if_statement from the tree entirely, so a
-- textual upward brace-scan covers that window.
local function success_check_var()
    local ok, var = pcall(function()
        local parser = vim.treesitter.get_parser(0)
        if parser then
            local tree = parser:parse()[1]
            if tree then
                local pos = vim.api.nvim_win_get_cursor(0)
                local row = pos[1] - 1
                local node = tree:root():named_descendant_for_range(row, pos[2], row, pos[2])
                while node do
                    if node:type() == 'if_statement' then
                        local cond = node:field('condition')[1]
                        local stack = cond and { cond } or {}
                        while #stack > 0 do
                            local n = table.remove(stack)
                            if n:type() == 'member_access_expression' then
                                local name = n:field('name')[1]
                                local obj = n:field('expression')[1]
                                if name and obj and vim.treesitter.get_node_text(name, 0) == 'Success' then
                                    return vim.treesitter.get_node_text(obj, 0)
                                end
                            end
                            for c in n:iter_children() do
                                if c:named() then stack[#stack + 1] = c end
                            end
                        end
                    end
                    node = node:parent()
                end
            end
        end

        -- fallback: nearest line above with an unmatched '{' opens our block;
        -- accept only if it is an if checking .Success
        local row = vim.api.nvim_win_get_cursor(0)[1] - 1
        local lines = vim.api.nvim_buf_get_lines(0, math.max(0, row - 60), row, false)
        local depth = 0
        for idx = #lines, 1, -1 do
            local line = lines[idx]
            local _, opens = line:gsub('{', '')
            local _, closes = line:gsub('}', '')
            depth = depth + closes - opens
            if depth < 0 then
                return line:match('if%s*%(%s*!?%s*([%w_%.]+)%s*%.Success')
            end
        end
    end)
    if not ok then return nil end
    return var
end

local function in_failed_result_if()
    return roslyn_attached() and success_check_var() ~= nil and enclosing_iresult_type() ~= nil
end

-- Logging receiver for the enclosing class: 'logger_' when the class declares
-- it, 'api_.Logger' when it declares api_ instead. When neither is declared
-- locally (e.g. inherited members), falls back to the convention already used
-- in the buffer, then to logger_.
local function log_receiver()
    local ok, recv = pcall(function()
        local parser = vim.treesitter.get_parser(0)
        if parser then
            local tree = parser:parse()[1]
            if tree then
                local pos = vim.api.nvim_win_get_cursor(0)
                local row = pos[1] - 1
                local node = tree:root():named_descendant_for_range(row, pos[2], row, pos[2])
                while node and node:type() ~= 'class_declaration' do
                    node = node:parent()
                end
                local body = node and node:field('body')[1]
                if body then
                    local names = {}
                    local function declarator_name(n)
                        local name = n:field('name')[1]
                        if not name then
                            local c0 = n:named_child(0)
                            if c0 and c0:type() == 'identifier' then name = c0 end
                        end
                        return name
                    end
                    for member in body:iter_children() do
                        local mt = member:type()
                        if mt == 'field_declaration' then
                            local stack = { member }
                            while #stack > 0 do
                                local n = table.remove(stack)
                                if n:type() == 'variable_declarator' then
                                    local name = declarator_name(n)
                                    if name then names[vim.treesitter.get_node_text(name, 0)] = true end
                                end
                                for c in n:iter_children() do
                                    if c:named() then stack[#stack + 1] = c end
                                end
                            end
                        elseif mt == 'property_declaration' then
                            local name = member:field('name')[1]
                            if name then names[vim.treesitter.get_node_text(name, 0)] = true end
                        end
                    end
                    if names['logger_'] then return 'logger_' end
                    if names['api_'] then return 'api_.Logger' end
                end
            end
        end

        local text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')
        if text:find('logger_%.Log%(') then return 'logger_' end
        if text:find('api_%.Logger%.Log%(') then return 'api_.Logger' end
    end)
    if not ok then return 'logger_' end
    return recv or 'logger_'
end

-- Summary block, plus <param>/<returns> tags for the function below the cursor.
local function doc_nodes(_, parent)
    local env = parent and parent.snippet and parent.snippet.env or {}
    local row0 = tonumber(env.TM_LINE_INDEX) or (vim.api.nvim_win_get_cursor(0)[1] - 1)

    local nodes = { t({ '/// <summary>', '/// ' }), i(1), t({ '', '/// </summary>' }) }
    local idx = 1

    local fn = next_function_below(row0)
    if fn then
        local params = fn:field('parameters')[1]
        if params then
            for p in params:iter_children() do
                if p:named() and p:type() == 'parameter' then
                    local name_node = p:field('name')[1]
                    if name_node then
                        idx = idx + 1
                        vim.list_extend(nodes, {
                            t({ '', '/// <param name="' .. vim.treesitter.get_node_text(name_node, 0) .. '">' }),
                            i(idx),
                            t('</param>'),
                        })
                    end
                end
            end
        end

        -- no <returns> for void or plain (non-generic) Task
        local ret = fn:field('returns')[1]
        local ret_text = ret and vim.treesitter.get_node_text(ret, 0)
        if ret_text and ret_text ~= 'void' and ret_text ~= 'Task' then
            idx = idx + 1
            vim.list_extend(nodes, { t({ '', '/// <returns>' }), i(idx), t('</returns>') })
        end
    end

    return sn(nil, nodes)
end

return {
    s(
        { trig = 'doc', name = 'doc', dscr = 'XML doc comment for the function below (params/returns)' },
        { d(1, doc_nodes) },
        roslyn_only
    ),
    s(
        { trig = 'rfail', name = 'rfail', dscr = 'return <logger>.Log(...).CreateFailedResult<T>; receiver and T from context' },
        {
            d(1, function()
                local T = enclosing_iresult_type() or 'object'
                return sn(nil, {
                    t('return ' .. log_receiver() .. '.Log(EventId.'),
                    i(1, 'eventid'),
                    t(', '),
                    i(2, 'null'),
                    t(', new { '),
                    i(3),
                    t({ ' })', '    .CreateFailedResult<' .. T .. '>(Api.ResultCode.' }),
                    i(4, 'BadRequest'),
                    t(');'),
                })
            end),
        },
        iresult_only
    ),
    s(
        {
            trig = 'rwrap',
            name = 'rwrap',
            dscr = 'return Api.Result<T>.CreateFailed(result); var from the enclosing !x.Success if, T from the enclosing function',
        },
        {
            d(1, function()
                local T = enclosing_iresult_type() or 'object'
                local var = success_check_var() or 'result'
                return sn(nil, {
                    t('return Api.Result<' .. T .. '>.CreateFailed(' .. var .. ');'),
                })
            end),
        },
        {
            condition = in_failed_result_if,
            show_condition = in_failed_result_if,
        }
    ),
    s(
        { trig = 'tfunc', name = 'tfunc', dscr = 'Async method returning Api.IResult<T>' },
        {
            t('public async Task<Api.IResult<'),
            i(1, 'object'),
            t('>> '),
            i(2, 'FunctionName'),
            t({ '()', '{', '    ' }),
            i(0),
            t({ '', '    return Api.Result<' }),
            rep(1),
            t({ '>.CreateSuccessful();', '}' }),
        },
        roslyn_only
    ),
}
