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

-- 3. lua_ls 专属配置
vim.lsp.config("lua_ls", {
	cmd = { "lua-language-server" }, -- 缺了这个一样不会启动
	filetypes = { "lua" },
	root_markers = { ".luarc.json", ".luarc.lua" },
})

-- 4. 统一启用
vim.lsp.enable({ "pyright", "lua_ls" })
