return {
	-- 中文帮助文档
	-- { "yianwillis/vimcdoc", priority = 1000 },

	-- 按键提示
	{ "folke/which-key.nvim", priority = 10000 },

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
		-- lazy = false,
		build = ":TSUpdate",
	},

	-- 括号颜色
	{ "HiPhish/rainbow-delimiters.nvim" },

	-- 撤销树
	{ "XXiaoA/atone.nvim" },

	-- LSP
	{
		"mason-org/mason-lspconfig.nvim",
		ft = { "lua", "python", "css", "html" },
		opts = {},
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
		},
	},
	{
		"hrsh7th/nvim-cmp",
		ft = { "lua", "python", "css", "html" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
		},
		config = function()
			require("cmp-config") -- 调用单独的配置文件
		end,
	},
	-- 格式化
	{ "stevearc/conform.nvim", ft = { "lua", "python", "css", "html" } },

	-- 括号补全
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true, -- 默认配置即可满足日常需求
		opts = {
			check_ts = true, -- 启用 Treesitter 支持，避免在字符串或注释中误触发
		},
	},

	--缓冲区
	{ "akinsho/bufferline.nvim", version = "*", dependencies = "nvim-tree/nvim-web-devicons" },

	-- git提示
	{ "lewis6991/gitsigns.nvim" },
	-- telescope
	{
		"nvim-telescope/telescope.nvim",
		version = "*",
		dependencies = {
			"nvim-lua/plenary.nvim",
			-- optional but recommended
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
	},

	-- 翻译
	{
		"noir4y/comment-translate.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
}
