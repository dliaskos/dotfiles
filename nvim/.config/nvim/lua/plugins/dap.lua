return {
	"mfussenegger/nvim-dap",

	dependencies = {
		"rcarriga/nvim-dap-ui",
		"leoluz/nvim-dap-go",
		"nicholasmata/nvim-dap-cs",
	},

	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		dapui.setup({
			floating = {
				max_height = 0.5,
				max_width = 0.5,
				border = "rounded",
			},
		})

		-- dap.set_log_level("TRACE")

		dap.listeners.before.attach.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.event_exited.dapui_config = function()
			dapui.close()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
			dapui.close()
		end

		vim.fn.sign_define("DapBreakpoint", { text = "🛑", texthl = "DapBreakpoint", linehl = "", numhl = "" })
		vim.fn.sign_define(
			"DapBreakpointCondition",
			{ text = "🔍", texthl = "DapBreakpoint", linehl = "", numhl = "" }
		)
		vim.fn.sign_define(
			"DapBreakpointRejected",
			{ text = "🚫", texthl = "DapBreakpoint", linehl = "", numhl = "" }
		)
		vim.fn.sign_define("DapLogPoint", { text = "📝", texthl = "DapLogPoint", linehl = "", numhl = "" })
		vim.fn.sign_define("DapStopped", { text = "▶️", texthl = "DapStopped", linehl = "Visual", numhl = "" })

		vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Resume/Continue" })
		vim.keymap.set("n", "<F8>", dap.step_over, { desc = "Debug: Step Over" })
		vim.keymap.set("n", "<F7>", dap.step_into, { desc = "Debug: Step Into" })
		vim.keymap.set("n", "<S-F8>", dap.step_out, { desc = "Debug: Step Out" })
		vim.keymap.set("n", "<F9>", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })

		vim.keymap.set("n", "<F10>", function()
			dapui.eval()
		end, { desc = "Debug: Evaluate" })

		vim.keymap.set("n", "<leader>dt", function()
			require("dap-go").debug_test()
		end, { desc = "Debug: Test" })

		require("dap-go").setup()

		local netcoredbg_path = "/Users/jliaskos/Devel/netcoredbg-macOS-arm64.nvim/netcoredbg/netcoredbg"

		dap.adapters.netcoredbg = {
			type = "executable",
			command = netcoredbg_path,
			args = { "--interpreter=vscode" },
		}

		require("dap-cs").setup({
			netcoredbg = {
				path = netcoredbg_path,
			},
		})
	end,
}
