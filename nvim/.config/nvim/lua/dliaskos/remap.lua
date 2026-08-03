vim.keymap.set("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
vim.keymap.set("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })
vim.keymap.set("n", "[l", vim.cmd.cprev, { desc = "Previous Location" })
vim.keymap.set("n", "]l", vim.cmd.cnext, { desc = "Next Location" })

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set('n', '<A-h>', '<C-w>h', { desc = 'Move to left split' })
vim.keymap.set('n', '<A-j>', '<C-w>j', { desc = 'Move to below split' })
vim.keymap.set('n', '<A-k>', '<C-w>k', { desc = 'Move to above split' })
vim.keymap.set('n', '<A-l>', '<C-w>l', { desc = 'Move to right split' })

-- Quick global marks: Alt to jump
for _, letter in ipairs({ 'u', 'i', 'o', 'p' }) do
    local upper = string.upper(letter)
    vim.keymap.set('n', '<A-' .. letter .. '>', '`' .. upper, { desc = 'Jump to mark ' .. upper })
end

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
