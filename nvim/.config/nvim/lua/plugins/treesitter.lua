return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        -- this is not entirely correct... not all parsers have the same filetype pattern.
        -- TODO: check what needs to be done later
        local parsers = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc',
            'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc', 'go', 'c_sharp', 'cs' }

        require("nvim-treesitter").setup({
            ensure_installed = parsers
        })

        vim.api.nvim_create_autocmd("FileType", {
            pattern = parsers,
            callback = function() vim.treesitter.start() end,
        })
    end
}
