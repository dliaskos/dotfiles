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

        vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })

        vim.keymap.set('n', '<leader>sg', function() builtin.live_grep({ additional_args = { "--hidden" } }) end,
            { desc = '[S]earch by [G]rep' })

        vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
        vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })

        -- new ones
        vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
        vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
        vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
        vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })


        vim.keymap.set('n', '<leader>/', function()
            -- You can pass additional configuration to Telescope to change the theme, layout, etc.
            builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                winblend = 20,
                previewer = false,
            })
        end, { desc = '[/] Fuzzily search in current buffer' })

        -- This runs on LSP attach per buffer (see main LSP attach function in 'neovim/nvim-lspconfig' config for more info,
        -- it is better explained there). This allows easily switching between pickers if you prefer using something else!
        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
            callback = function(event)
                local buf = event.buf

                -- Find references for the word under your cursor.
                vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })

                -- Jump to the implementation of the word under your cursor.
                -- Useful when your language has ways of declaring types without an actual implementation.
                vim.keymap.set('n', 'gri', builtin.lsp_implementations,
                    { buffer = buf, desc = '[G]oto [I]mplementation' })

                -- Jump to the definition of the word under your cursor.
                -- This is where a variable was first declared, or where a function is defined, etc.
                -- To jump back, press <C-t>.
                vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })

                -- Fuzzy find all the symbols in your current document.
                -- Symbols are things like variables, functions, types, etc.
                vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })

                -- Fuzzy find all the symbols in your current workspace.
                -- Similar to document symbols, except searches over your entire project.
                vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols,
                    { buffer = buf, desc = 'Open Workspace Symbols' })

                -- Jump to the type of the word under your cursor.
                -- Useful when you're not sure what type a variable is and you want to see
                -- the definition of its *type*, not where it was *defined*.
                vim.keymap.set('n', 'grt', builtin.lsp_type_definitions,
                    { buffer = buf, desc = '[G]oto [T]ype Definition' })
            end,
        })
    end,
}
