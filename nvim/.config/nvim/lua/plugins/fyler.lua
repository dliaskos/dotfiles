return {
    "A7Lavinraj/fyler.nvim",
    dependencies = { "nvim-mini/mini.icons" },
    branch = "stable", -- Use stable branch for production
    lazy = false,      -- Necessary for `default_explorer` to work properly
    opts = {},
    keys = {
        {
            "<leader>e",
            function() require("fyler").toggle({ kind = "split_left_most" }) end,
            { desc = "Open Fyler View" }
        },
    }
}
