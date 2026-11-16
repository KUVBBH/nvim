-- 1. 全局通用配置（所有 LSP 自动生效，不用重复写）
vim.lsp.config("*", {
	root_markers = { ".git" }, -- 通用的兜底标记
	-- capabilities = require("cmp_nvim_lsp").default_capabilities(), -- 如果你用补全插件，把这行加上
})

-- 2. pyright 专属配置
vim.lsp.config("pyright", {
	cmd = { "pyright-langserver", "--stdio" }, -- 必须有！Mason 已在 PATH 里
	filetypes = { "python" },
	root_markers = { "pyrightconfig.json", "pyproject.toml", "setup.py" }, -- 专属标记（自动叠加全局的 .git）
	settings = {
		pyright = { disableTaggedHints = true },
		python = {
			analysis = {
				autoSearchPaths = true,
				diagnosticMode = "openFilesOnly",
				useLibraryCodeForTypes = true,
			},
		},
	},
})

-- 自动高亮光标下的引用（保持原样）
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
	callback = vim.lsp.buf.document_highlight,
})
vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
	callback = vim.lsp.buf.clear_references,
})

-- 用一个函数来设置高亮，防止被主题覆盖
local function set_highlight_colors()
	-- LspReferenceText: 文本引用
	-- LspReferenceRead: 读取引用
	-- LspReferenceWrite: 写入引用

	-- 这里使用：亮黄绿色背景 + 黑色文字 + 加粗
	-- 如果想换成其他颜色，可以把 #b4f9f8 换成：
	-- 亮黄色: #f9e2af | 亮紫色: #cba6f7 | 亮粉色: #f5c2e7
	vim.api.nvim_set_hl(0, "LspReferenceText", { bg = "#b4f9f8", fg = "#000000", bold = true })
	vim.api.nvim_set_hl(0, "LspReferenceRead", { bg = "#b4f9f8", fg = "#000000", bold = true })
	vim.api.nvim_set_hl(0, "LspReferenceWrite", { bg = "#b4f9f8", fg = "#000000", bold = true, underline = true })
end

-- 立即执行一次
set_highlight_colors()

-- 每次切换主题时，重新执行一次
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = set_highlight_colors,
})
-- 3. lua_ls 专属配置
vim.lsp.config("lua_ls", {
	cmd = { "lua-language-server" }, -- 缺了这个一样不会启动
	filetypes = { "lua" },
	root_markers = { ".luarc.json", ".luarc.lua" },
})

-- 4. 统一启用
vim.lsp.enable({ "pyright", "lua_ls" })
