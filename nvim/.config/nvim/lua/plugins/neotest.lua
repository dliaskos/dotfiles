return {
    "nvim-neotest/neotest",

    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "nsidorenco/neotest-vstest",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    keys = {
        {
            "<leader>tr",
            function()
                require("neotest").run.run()
            end,
            desc = "Run nearest test",
        },
        {
            "<leader>tf",
            function()
                require("neotest").run.run(vim.fn.expand("%")) 
            end,
            desc = "Run all tests in file",
        },
        {
            "<leader>tp",
            function()
                require("neotest").output_panel.toggle()
            end,
            desc = "Toggle test output panel",
        },
        {
            "<leader>td",
            function()
                require("neotest").run.run({ strategy = "dap" })
            end,
            desc = "Debug nearest test",
        },
        {
            "<leader>td",
            function()
                require("neotest").summary.toggle()
            end,
            desc = "Toggle test summary",
        },
    },
    config = function()
        require("neotest").setup({
            log_level = vim.log.levels.DEBUG,
            adapters = {
                require("neotest-vstest"),
            },
        })
    end,
}

-- return {
--     "nvim-neotest/neotest",
--     dependencies = {
--         "nvim-neotest/nvim-nio",
--         "nvim-lua/plenary.nvim",
--         "antoinemadec/FixCursorHold.nvim",
--         "nvim-treesitter/nvim-treesitter",
--         "nsidorenco/neotest-vstest",
--     },
--     config = function()
--         -- NOTE: This should be set before calling require("neotest-vstest")
--         vim.g.neotest_vstest = {
--             -- Path to dotnet sdk path.
--             -- Used in cases where the sdk path cannot be auto discovered.
--             --sdk_path = "/usr/local/dotnet/sdk/9.0.101/",
--             -- table is passed directly to DAP when debugging tests.
--             dap_settings = {
--                 type = "netcoredbg",
--             },
--             -- If multiple solutions exists the adapter will ask you to choose one.
--             -- If you have a different heuristic for choosing a solution you can provide a function here.
--             solution_selector = function(solutions)
--                 return nil -- return the solution you want to use or nil to let the adapter choose.
--             end,
--             -- If multiple .runsettings/testconfig.json files are present in the test project directory
--             -- you will be given the choice of file to use when setting up the adapter.
--             -- Or you can provide a function here
--             -- default nil to select from all files in project directory
--             settings_selector = function(project_dir)
--                 return nil -- return the .runsettings/testconfig.json file you want to use or let the adapter choose
--             end,
--             build_opts = {
--                 -- Arguments that will be added to all dotnet build and dotnet msbuild commands
--                 additional_args = {},
--             },
--             timeout_ms = 30 * 5 * 1000, -- number of milliseconds to wait before timeout while communicating with adapter client
--
--
--     end,
