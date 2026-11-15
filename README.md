
#### 字体

- Termux字体文件位置`~/.termux/`

#### LSP
'''lua
-- 配置 pyright（注意：把 cmd 路径换成你 Mason 的绝对路径）
vim.lsp.config("pyright", {
	cmd = { vim.fn.expand("pyright-langserver"), "--stdio" },
	filetypes = { "python" },
	root_markers = {
		"pyrightconfig.json",
		"pyproject.toml",
		"setup.py",
		"setup.cfg",
		"requirements.txt",
		"Pipfile",
		".git",
	},
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

-- 启用 pyright
vim.lsp.enable("pyright")
'''


#### 环境变量 > `.bashrc`


- RUST`export PATH="$HOME/.cargo/bin:$PATH"`
- MASON`export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"`


#### Termux

LUA`pkg install lua-language-server`
