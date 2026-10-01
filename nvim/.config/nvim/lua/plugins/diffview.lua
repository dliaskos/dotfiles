local toggleDiffview = function(rev)
    local df = require("diffview")
    local lib = require("diffview.lib")
    local view = lib.get_current_view()

    if view then
        df.close()
    else
        if rev then
            df.open(rev)
        else
            df.open()
        end
    end
end

return {
    "sindrets/diffview.nvim",

    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        local diffview = require("diffview")
        vim.opt.fillchars:append({ diff = "╱" })

        diffview.setup({
            enhanced_diff_hl = true,
            file_panel = {
                win_config = function()
                    return {
                        position = "left",
                        width = math.max(40, math.floor(vim.o.columns * 0.25)),
                    }
                end,
            },
            view = {
                merge_tool = {
                    layout = "diff3_mixed",
                },
            },
        })
    end,
    keys = {
        {
            "<leader>dfl",
            desc = "Toggle Diffview for local changes",
            function()
                toggleDiffview()
            end,
        },
        {
            "<leader>dfr",
            desc = "Toggle Diffview for remote changes",
            function()
                toggleDiffview("origin/current...HEAD")
            end,
        },
    },
}
