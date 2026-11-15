-- ~/.config/nvim/lua/formatter.lua
local ok, conform = pcall(require, "conform")
if not ok then
	return
end

-- 这里就是你原来代码里的 opts 部分，一字不差
conform.setup({
	formatters_by_ft = {
		python = { "black" },
		lua = { "stylua" },
		-- 想加别的语言直接在这里加，例如：
		-- lua = { "stylua" },
		-- javascript = { "prettierd", "prettier", stop_after_first = true },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
	notify_on_error = true,
})
