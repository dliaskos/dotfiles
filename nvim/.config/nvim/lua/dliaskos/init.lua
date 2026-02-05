require("dliaskos.set")
require("dliaskos.remap")
require("config.lazy")

vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },

  -- Can switch between these as you prefer
  virtual_text = true, -- Text shows up at the end of the line
  virtual_lines = false, -- Teest shows up underneath the line, with virtual lines

  -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
  jump = { float = true },
}

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- local augroup = vim.api.nvim_create_augroup
-- local dliaskos = augroup('dliaskos', {})

-- local autocmd = vim.api.nvim_create_autocmd

-- autocmd('LspAttach', {
--     group = dliaskos,
--     callback = function(e)
--         local opts = { buffer = e.buf }
--
--         vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
--         vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
--
--         vim.keymap.set("n", "<leader>//", function() vim.lsp.buf.format() end, opts)
--         vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
--         vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
--         vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
--         vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, opts)
--         vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, opts)
--
--         vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
--         vim.keymap.set("n", "<leader>gr", function() vim.lsp.buf.references() end, opts)
--         vim.keymap.set("n", "<leader>rr", function() vim.lsp.buf.rename() end, opts)
--     end
-- })
--

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
