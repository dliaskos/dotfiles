vim.g.mapleader = " "

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set('n', '<A-h>', '<C-w>h', { desc = 'Move to left split' })
vim.keymap.set('n', '<A-j>', '<C-w>j', { desc = 'Move to below split' })
vim.keymap.set('n', '<A-k>', '<C-w>k', { desc = 'Move to above split' })
vim.keymap.set('n', '<A-l>', '<C-w>l', { desc = 'Move to right split' })
