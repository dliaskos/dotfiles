return {
	"neovim/nvim-lspconfig",

	dependencies = {
		"mason-org/mason.nvim",
		"mason-org/mason-lspconfig.nvim",

		"seblyng/roslyn.nvim",

		"hrsh7th/nvim-cmp",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",


		-- "j-hui/fidget.nvim",
	},

	config = function()
		require("mason").setup({
			registries = {
				"github:mason-org/mason-registry",
				"github:Crashdummyy/mason-registry",
			},
		})

		require("mason-lspconfig").setup({
			ensure_installed = { "lua_ls", "gopls", "yamlls" },
		})

		require("roslyn").setup({
			env = {
				DOTNET_ROLL_FORWARD = "LatestMajor",
			},
		})

		local cmp = require("cmp")
		local windowOptions = {
			focusable = false,
			style = "minimal",
			border = "rounded",
			source = "always",
			header = "",
			prefix = "",
		}

		cmp.setup({
			mapping = cmp.mapping.preset.insert({
				["<C-Space>"] = cmp.mapping.complete(),
				-- ['<C-e>'] = cmp.mapping.abort(),
				["<C-y>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
			}),
			window = {
				completion = cmp.config.window.bordered(windowOptions),
				documentation = cmp.config.window.bordered(windowOptions),
			},
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
			}, { { name = "buffer" } }),
		})

		-- TODO: not working require("fidget").setup()

		vim.diagnostic.config({
			float = windowOptions,
		})
	end,
}
