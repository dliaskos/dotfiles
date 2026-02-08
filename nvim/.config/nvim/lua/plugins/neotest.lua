return {
    "nvim-neotest/neotest",

    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",

        -- "Issafalcon/neotest-dotnet",
        "nsidorenco/neotest-vstest",
    },

    config = function()
        local neotest = require 'neotest'

        neotest.setup({
            adapters = {
                require("neotest-vstest"),
            },
        })

        vim.keymap.set("n", "<leader>tr", function() require("neotest").run.run() end, opts)
        vim.keymap.set("n", "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, opts)
        vim.keymap.set("n", "<leader>ts", function() require("neotest").summary.toggle() end, opts)
    end,
}
