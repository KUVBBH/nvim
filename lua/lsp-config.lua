-- 1. 全局兜底配置
vim.lsp.config("*", {
	root_markers = { ".git" },
	-- 确保你的补全插件 cmp_nvim_lsp 已安装并加载，否则这里会报错
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

-- 2. basedpyright 专属配置
vim.lsp.config("basedpyright", {
	cmd = { "basedpyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_markers = { "pyrightconfig.json", "pyproject.toml", "setup.py", ".git" },
	settings = {
		basedpyright = {
			analysis = {
				autoSearchPaths = true,
				diagnosticMode = "openFilesOnly",
				useLibraryCodeForTypes = true,
			},
		},
		python = {
			-- Termux 环境必备：告诉 LSP 去哪里找 Python 解释器和标准库(os, sys等)
			pythonPath = "/data/data/com.termux/files/usr/bin/python3",
			analysis = {
				autoSearchPaths = true,
				diagnosticMode = "openFilesOnly",
				useLibraryCodeForTypes = true,
			},
		},
	},
})

-- 自动高亮光标下的引用
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
	buffer = 0,
	callback = vim.lsp.buf.document_highlight,
})
vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
	buffer = 0,
	callback = vim.lsp.buf.clear_references,
})

-- 设置高亮颜色
local function set_highlight_colors()
	vim.api.nvim_set_hl(0, "LspReferenceText", { bg = "#b4f9f8", fg = "#000000", bold = true })
	vim.api.nvim_set_hl(0, "LspReferenceRead", { bg = "#b4f9f8", fg = "#000000", bold = true })
	vim.api.nvim_set_hl(0, "LspReferenceWrite", { bg = "#b4f9f8", fg = "#000000", bold = true, underline = true })
end

set_highlight_colors()

vim.api.nvim_create_autocmd("ColorScheme", {
	callback = set_highlight_colors,
})

-- 3. lua_ls 专属配置
vim.lsp.config("lua_ls", {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = { ".luarc.json", ".luarc.lua", ".git" },
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
			telemetry = { enable = false },
		},
	},
})

-- 4. 统一启用（关键：没有这行，LSP 绝对不会启动）
vim.lsp.enable({ "basedpyright", "lua_ls" })
