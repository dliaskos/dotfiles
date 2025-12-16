vim.lsp.config('gopls', {
	cmd = { 'gopls' },
	filetypes = { 'go', 'gotempl', 'gowork', 'gomod' },
	root_markers = { '.git', 'go.mod', 'go.work' },
    settings = {
        gopls = {
            completeUnimported = true,
            usePlaceholders = true,
            analyses = {
                unusedparams = true,
            },
            ["ui.inlayhint.hints"] = {
                compositeLiteralFields = true,
                constantValues = true,
                parameterNames = true,
                rangeVariableTypes = true,
            },
        },
    },
})

vim.lsp.config('luals', {
	cmd = { 'lua-language-server' },
	filetypes = { 'lua' },
	root_markers = { '.luarc.json', '.luarc.jsonc' },
})

vim.lsp.enable('bashls')
vim.lsp.enable('luals')
vim.lsp.enable('gopls')
