-- 1. 全局兜底配置
vim.lsp.config("*", {
	root_markers = { ".git" },
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

-- 4. 自动高亮光标下的引用：必须挂到 LspAttach 并按 buffer 生效
local aug = vim.api.nvim_create_augroup("UserLspDocumentHighlight", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
	group = aug,
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if not client or not client:supports_method("textDocument/documentHighlight") then
			return
		end

		local buf = ev.buf
		vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
			group = aug,
			buffer = buf,
			callback = function()
				vim.lsp.buf.document_highlight()
			end,
		})
		vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
			group = aug,
			buffer = buf,
			callback = function()
				vim.lsp.buf.clear_references()
			end,
		})
	end,
})

-- 设置高亮颜色：不写死 RGB，跟随主题，避免暗色背景下刺眼
local function set_highlight_colors()
	vim.api.nvim_set_hl(0, "LspReferenceText", { bold = true, underline = true })
	vim.api.nvim_set_hl(0, "LspReferenceRead", { bold = true, underline = true })
	vim.api.nvim_set_hl(0, "LspReferenceWrite", { bold = true, underline = true })
end

set_highlight_colors()

vim.api.nvim_create_autocmd("ColorScheme", {
	callback = set_highlight_colors,
})

-- 5. 统一启用（没有这行，LSP 绝对不会启动）
vim.lsp.enable({ "basedpyright", "lua_ls" })
