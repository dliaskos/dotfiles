require("dliaskos.set")
require("dliaskos.remap")
require("config.lazy")

require("dliaskos.lsp")
require("dliaskos.git")

vim.diagnostic.config({
    virtual_text = true,
})

local augroup = vim.api.nvim_create_augroup
local dliaskos = augroup('dliaskos', {})

local autocmd = vim.api.nvim_create_autocmd

autocmd('LspAttach', {
    group = dliaskos,
    callback = function(e)
        local opts = { buffer = e.buf }

        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, opts)

        local client = vim.lsp.get_client_by_id(e.data.client_id)

        if not client then
            error(string.format("%s not found", e.data.client_id))

            return
        end

        if client:supports_method('textDocument/completion') then

          -- Enable auto-completion
          vim.lsp.completion.enable(true, client.id, e.buf, { autotrigger = true })
          vim.opt.completeopt = { "menuone", "noselect", "noinsert" }
        end

        if client:supports_method('textDocument/signatureHelp') then
          vim.api.nvim_create_autocmd("CursorHoldI", {
            buffer = e.buf,
            callback = function()
              -- This triggers the signature help window automatically
              vim.lsp.buf.signature_help()
            end,
          })
        end
    end
})


vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
