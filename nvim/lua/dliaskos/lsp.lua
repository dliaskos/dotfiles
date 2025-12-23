vim.lsp.config('roslyn', {
    cmd = {
        "dotnet",
        "/Users/jliaskos/roslyn/lib/net10.0/Microsoft.CodeAnalysis.LanguageServer.dll",
        "--logLevel", -- this property is required by the server
        "Information",
        "--extensionLogDirectory", -- this property is required by the server
        vim.fs.joinpath(vim.uv.os_tmpdir(), "roslyn_ls/logs"),
        "--stdio"
    },
    filetypes = { 'cs' },
    root_markers = { '.git', '.sln' }
})

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

vim.lsp.config('yamlls', {
    cmd = { "yaml-language-server", "--stdio" },
    settings = {
        yaml = {
            schema = {
                ["https://www.schemastore.org/kustomization.json"] = "/**/.kubernetes/*.{yaml,yml}"
            },
            format = {
                enable = true,
                singleQuote = false,
                bracketSpacing = true,
            },
            hover = true,
            validate = true,
            completion = true,
        }
    },
	filetypes = { 'yml', 'yaml' },
	root_markers = { '.git' },
})

vim.lsp.config('lua_ls', {
	cmd = { 'lua-language-server' },
	filetypes = { 'lua' },
	root_markers = { '.luarc.json', '.luarc.jsonc' },
})

vim.lsp.enable('lua_ls')
vim.lsp.enable('gopls')
vim.lsp.enable('roslyn')
-- vim.lsp.enable('yamlls')
