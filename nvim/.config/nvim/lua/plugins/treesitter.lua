-- return { -- Highlight, edit, and navigate code
--     'nvim-treesitter/nvim-treesitter',
--     lazy = false,
--     config = function()
--       local filetypes = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }
--       -- require('nvim-treesitter').install(filetypes)
--       require('nvim-treesitter').setup({
--
--       })
--       vim.api.nvim_create_autocmd('FileType', {
--         pattern = filetypes,
--         callback = function() vim.treesitter.start() end,
--       })
--     end,
--   }
--
return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").setup({
            -- A list of parser names, or "all"
            install = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc', 'go'},

            -- Install parsers synchronously (only applied to `ensure_installed`)
            -- sync_install = false,
            --
            -- Automatically install missing parsers when entering buffer
            -- Recommendation: set to false if you don"t have `tree-sitter` CLI installed locally
            -- auto_install = true,

            indent = {
                enable = true
            },

            highlight = {
                -- `false` will disable the whole extension
                enable = true,

                -- setting this to true will run `:h syntax` and tree-sitter at the same time.
                -- set this to `true` if you depend on "syntax" being enabled (like for indentation).
                -- using this option may slow down your editor, and you may see some duplicate highlights.
                -- instead of true it can also be a list of languages
                additional_vim_regex_highlighting = { "markdown" },
            },
        })
    end
}
