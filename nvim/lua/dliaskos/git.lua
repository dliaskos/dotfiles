-- Create an autocommand group for Git-related tasks
local git_group = vim.api.nvim_create_augroup("GitCommitPrefix", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = git_group,
  pattern = "gitcommit",
  callback = function()
    -- Get the current branch name
    local branch = vim.fn.systemlist("git rev-parse --abbrev-ref HEAD")[1]
    if not branch or branch == "" then return end

    -- Extract ticket ID (e.g., CORE-728) using Lua patterns
    -- %a+ is letters, %d+ is numbers
    local ticket = branch:match("(%a+%-%d+)")

    if ticket then
      ticket = ticket:upper() .. ": "
      
      -- Get the first line of the buffer
      local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
      
      -- Prepend the ticket if the line doesn't already start with it
      if first_line and not first_line:find("^" .. ticket) then
        vim.api.nvim_buf_set_lines(0, 0, 1, false, { ticket .. first_line })
        -- Move the cursor to the end of the new prefix
        vim.api.nvim_win_set_cursor(0, {1, #ticket})

        vim.cmd("startinsert!")
      end
    end
  end,
})
