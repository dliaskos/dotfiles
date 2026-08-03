return {
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {},
  -- Optional dependencies
  -- dependencies = { { "nvim-mini/mini.icons", opts = {} } },
  dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
  lazy = false,
  config = function ()
    require("oil").setup({
      keymaps = {
        ["<CR>"] = { "actions.select", opts = { close = true } },
        ["<leader>e"] = { "actions.close", opts = { exit_if_last_buf = false } },
      },
    })
    vim.keymap.set("n", "<leader>e", "<CMD>Oil --float<CR>", { desc = "Open parent directory" }) 
  end
}
