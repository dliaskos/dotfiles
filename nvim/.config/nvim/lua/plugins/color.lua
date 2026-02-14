return {
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    -- 'rebelot/kanagawa.nvim',
    'catppuccin/nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function()
        vim.cmd.colorscheme 'catppuccin-mocha'
    end,
}
