-- ~/.config/nvim/lua/formatter.lua
local conform = require("conform")

conform.setup({
	formatters_by_ft = {
		python = { "black" },
		lua = { "stylua" },
		-- 想加别的语言直接在这里加，例如：
		-- javascript = { "prettierd", "prettier", stop_after_first = true },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
	notify_on_error = true,
})
