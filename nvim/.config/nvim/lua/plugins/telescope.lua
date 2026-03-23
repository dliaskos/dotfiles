return {
    "nvim-telescope/telescope.nvim",

    dependencies = {
        "nvim-lua/plenary.nvim",
        { -- If encountering errors, see telescope-fzf-native README for installation instructions
            'nvim-telescope/telescope-fzf-native.nvim',

            -- `build` is used to run some command when the plugin is installed/updated.
            -- This is only run then, not every time Neovim starts up.
            build = 'make',

            -- `cond` is a condition used to determine whether this plugin should be
            -- installed and loaded.
            cond = function() return vim.fn.executable 'make' == 1 end,
        },
        { 'nvim-telescope/telescope-ui-select.nvim' },

        -- Useful for getting pretty icons, but requires a Nerd Font.
        { 'nvim-tree/nvim-web-devicons',            enabled = vim.g.have_nerd_font },
    },

    config = function()
        require("telescope").setup({
            defaults = {
                file_ignore_patterns = {
                    "%.DS_Store",
                    "%.git/",
                },
            },
            pickers = {
                find_files = {
                    hidden = true, -- Keep this to see .env, .config, etc.
                },
            },
            extensions = {
                ['ui-select'] = { require('telescope.themes').get_dropdown() },
            },
        })

        -- Enable Telescope extensions if they are installed
        pcall(require('telescope').load_extension, 'fzf')
        pcall(require('telescope').load_extension, 'ui-select')

        local builtin = require("telescope.builtin")

        vim.keymap.set("n", "<leader>ff", function()
            builtin.find_files()
        end, {})

        vim.keymap.set("n", "<leader>fb", builtin.buffers, {})

        vim.keymap.set("n", "<leader>pws", function()
            local word = vim.fn.expand("<cword>")
            builtin.grep_string({ search = word })
        end)

        vim.keymap.set("n", "<leader>pWs", function()
            local word = vim.fn.expand("<cWORD>")
            builtin.grep_string({ search = word })
        end)

        vim.keymap.set("n", "<leader>fg", function()
            builtin.live_grep({ additional_args = { "--hidden" } })
        end, { desc = "Telescope live grep" })

        vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
    end,
}
