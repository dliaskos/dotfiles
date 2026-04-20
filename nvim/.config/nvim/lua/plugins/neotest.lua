return {
    "nvim-neotest/neotest",

    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",

        "Issafalcon/neotest-dotnet",
        -- "nsidorenco/neotest-vstest",
    },

    config = function()
        local neotest = require 'neotest'

        neotest.setup({
            discovery = {
                enabled = false,
            },
            adapters = {
                require("neotest-dotnet"),
            },
        })

        vim.keymap.set("n", "<leader>tr", function() neotest.run.run() end, opts)
        vim.keymap.set("n", "<leader>tf", function() neotest.run.run(vim.fn.expand("%")) end, opts)
        vim.keymap.set("n", "<leader>ts", function() neotest.summary.toggle() end, opts)
        vim.keymap.set("n", "<leader>tp", function() neotest.output_panel.toggle() end, opts)

    end,
}
