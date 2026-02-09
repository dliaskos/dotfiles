return {
    'neovim/nvim-lspconfig',
    dependencies = {
        -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
        -- and elegantly composed help section, `:help lsp-vs-treesitter`
        --
        -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
        {
            'mason-org/mason.nvim',
            opts = {
                registries = {
                    "github:mason-org/mason-registry",
                    "github:Crashdummyy/mason-registry",
                },
            }
        },

        'WhoIsSethDaniel/mason-tool-installer.nvim',
        "seblyng/roslyn.nvim",

        -- Useful status updates for LSP.
        { 'j-hui/fidget.nvim', opts = {} },

        -- Allows extra capabilities provided by blink.cmp
        'saghen/blink.cmp',
    },
    config = function()
        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
            callback = function(event)
                -- TODO: check this inlay hint later
                -- This may be unwanted, since they displace some of your code
                -- if client and client:supports_method('textDocument/inlayHint', event.buf) then
                --   map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
                -- end

                local opts = { buffer = event.buf }
                vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
                vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)

                vim.keymap.set("n", "<leader>//", function() vim.lsp.buf.format() end, opts)
                vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
                vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
                vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
                vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, opts)
                vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, opts)

                vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
                vim.keymap.set("n", "gr", function() vim.lsp.buf.references() end, opts)
                vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts)
                -- Execute a code action, usually your cursor needs to be on top of an error
                -- or a suggestion from your LSP for this to activate.
                -- map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

                -- WARN: This is not Goto Definition, this is Goto Declaration.
                --  For example, in C this would take you to the header.
                -- map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
                local client = vim.lsp.get_client_by_id(event.data.client_id)
                if client and client:supports_method('textDocument/documentHighlight', event.buf) then
                    local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
                    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.document_highlight,
                    })

                    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.clear_references,
                    })

                    vim.api.nvim_create_autocmd('LspDetach', {
                        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
                        callback = function(event2)
                            vim.lsp.buf.clear_references()
                            vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
                        end,
                    })
                end
            end,
        })

        local capabilities = require('blink.cmp').get_lsp_capabilities()
        local servers = { gopls = {} }
        local ensure_installed = vim.tbl_keys(servers or {})

        vim.list_extend(ensure_installed, {
            'roslyn',
            'lua-language-server',
            'stylua',
        })

        require('mason-tool-installer').setup { ensure_installed = ensure_installed }

        for name, server in pairs(servers) do
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            vim.lsp.config(name, server)
            vim.lsp.enable(name)
        end

        vim.lsp.config('lua_ls', {
            on_init = function(client)
                if client.workspace_folders then
                    local path = client.workspace_folders[1].name
                    if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
                end

                client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                    runtime = {
                        version = 'LuaJIT',
                        path = { 'lua/?.lua', 'lua/?/init.lua' },
                    },
                    workspace = {
                        checkThirdParty = false,
                        -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
                        --  See https://github.com/neovim/nvim-lspconfig/issues/3189
                        library = vim.api.nvim_get_runtime_file('', true),
                    },
                })
            end,
            settings = {
                Lua = {},
            },
        })
        vim.lsp.enable 'lua_ls'

        require("roslyn").setup({
            env = {
                DOTNET_ROLL_FORWARD = "LatestMajor",
            },
        })
    end,
}
