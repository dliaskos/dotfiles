return {
    "sindrets/diffview.nvim",

    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },

    opts = {
        enhanced_diff_hl = true,
        view = {
            merge_tool = {
                layout = "diff3_mixed",
            },
        },
    },
    keys = {
        {
            "<leader>dv",
            desc = "Toggle Diffview",
            function()
                vim.opt.fillchars:append({ diff = "╱" })

                local lib = require("diffview.lib")
                local view = lib.get_current_view()

                if view then
                    require("diffview").close()
                else
                    require("diffview").open()
                end
            end,
        },
    },
}
