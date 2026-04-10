local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local function fetch_prs()
    local result = vim.fn.system(
        "gh pr list --json number,title,headRefName,baseRefName --limit 120 --search 'sort:created-desc'"
    )
    if vim.v.shell_error ~= 0 then
        vim.notify("Failed to fetch PRs: " .. result, vim.log.levels.ERROR)
        return nil
    end
    return vim.json.decode(result)
end

local function open_in_diffview(pr)
    vim.fn.system({ "git", "fetch", "origin", pr.baseRefName, pr.headRefName })
    vim.cmd("DiffviewOpen origin/" .. pr.baseRefName .. "...origin/" .. pr.headRefName)
end

local M = {}

function M.pick()
    local prs = fetch_prs()
    if not prs or #prs == 0 then
        vim.notify("No open pull requests found", vim.log.levels.WARN)
        return
    end

    pickers.new(require("telescope.themes").get_dropdown({
        winblend = 20,
        previewer = false,
    }), {
        prompt_title = "Pull Requests",
        finder = finders.new_table({
            results = prs,
            entry_maker = function(pr)
                local display = string.format("#%d %s", pr.number, pr.title)
                return {
                    value = pr,
                    display = display,
                    ordinal = pr.title,
                }
            end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, _)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if not selection then return end
                open_in_diffview(selection.value)
            end)
            return true
        end,
   }):find()
end

return M
