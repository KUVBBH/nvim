return {
	-- 中文帮助文档
	{ "yianwillis/vimcdoc", priority = 1000 },

	-- 按键提示
	{ "folke/which-key.nvim", priority = 500 },

	-- 主题
	{ "folke/tokyonight.nvim" },

	-- 状态栏
	{ "nvim-lualine/lualine.nvim" },

	-- 文件树
	{ "nvim-tree/nvim-tree.lua" },

	-- 图标
	{ "nvim-tree/nvim-web-devicons" },

	-- 语法高亮
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
	},

	-- 括号颜色
	{ "HiPhish/rainbow-delimiters.nvim" },

	-- LSP
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {},
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
		},
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
		},
		config = function()
			require("cmp-config") -- 调用单独的配置文件
		end,
	},
	{ "stevearc/conform.nvim" },
}
