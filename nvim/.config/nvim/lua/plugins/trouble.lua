return {
    "folke/trouble.nvim",
    opts = {
        modes = {
            diagnostics = {
                -- Match ]d/[d: Roslyn reports IDE suggestions/hints as diagnostics,
                -- so in .NET files only show errors; other filetypes stay unfiltered.
                filter = {
                    any = {
                        severity = vim.diagnostic.severity.ERROR,
                        function(item)
                            return not item.filename:match("%.cs$")
                        end,
                    },
                },
            },
        },
    },
    cmd = "Trouble",
    keys = {
        {
            "<leader>xx",
            "<cmd>Trouble diagnostics toggle<cr>",
            desc = "Diagnostics (Trouble)",
        },
        {
            "<leader>xX",
            "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
            desc = "Buffer Diagnostics (Trouble)",
        },
        {
            "<leader>cs",
            "<cmd>Trouble symbols toggle focus=false<cr>",
            desc = "Symbols (Trouble)",
        },
        {
            "<leader>cl",
            "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
            desc = "LSP Definitions / references / ... (Trouble)",
        },
        {
            "<leader>xL",
            "<cmd>Trouble loclist toggle<cr>",
            desc = "Location List (Trouble)",
        },
        {
            "<leader>xQ",
            "<cmd>Trouble qflist toggle<cr>",
            desc = "Quickfix List (Trouble)",
        },

        -- navigation
        {
            "]t",
            function()
                require("trouble").next({ skip_groups = true, jump = true });
            end,
            desc = "Next Trouble Item",
        },
        {
            "[t",
            function()
                require("trouble").prev({ skip_groups = true, jump = true });
            end,
            desc = "Previous Trouble Item",
        },
    },
}
