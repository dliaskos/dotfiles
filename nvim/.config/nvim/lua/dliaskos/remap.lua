vim.keymap.set("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
vim.keymap.set("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set('n', '<A-h>', '<C-w>h', { desc = 'Move to left split' })
vim.keymap.set('n', '<A-j>', '<C-w>j', { desc = 'Move to below split' })
vim.keymap.set('n', '<A-k>', '<C-w>k', { desc = 'Move to above split' })
vim.keymap.set('n', '<A-l>', '<C-w>l', { desc = 'Move to right split' })

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = 'Yank to clipboard' })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = 'Yank line to clipboard' })
vim.keymap.set('n', "<leader>p", [["+p]], { desc = 'Paste from clipboard' })