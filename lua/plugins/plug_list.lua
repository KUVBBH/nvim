return {
	-- 主题：优先加载，保证其它插件取色正确
	{
		"folke/tokyonight.nvim",
		priority = 1000,
		lazy = false,
		config = function()
			vim.cmd.colorscheme("tokyonight-moon")
		end,
	},

	-- 按键提示（启动即需要）
	{ "folke/which-key.nvim", priority = 9000, lazy = false },

	-- 图标（供文件树 / 状态栏 / telescope 使用）
	{ "nvim-tree/nvim-web-devicons" },

	-- 状态栏
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		config = function()
			require("lualine-config")
		end,
	},

	-- 文件树（netrw 已禁用，需要它在启动时就接管目录 buffer）
	{
		"nvim-tree/nvim-tree.lua",
		lazy = false,
		config = function()
			require("nvim-tree-config")
		end,
	},

	-- 顶部 buffer 标签
	{
		"akinsho/bufferline.nvim",
		version = "*",
		event = "VeryLazy",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("bufferline-config")
		end,
	},

	-- 语法高亮
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("treesitter-config")
		end,
	},

	-- 括号颜色（依赖 FileType 事件，启动即加载以免首个文件漏掉）
	{ "HiPhish/rainbow-delimiters.nvim", lazy = false },

	-- 撤销树（:Atone 触发加载）
	{
		"XXiaoA/atone.nvim",
		cmd = "Atone",
		config = function()
			require("atone-config")
		end,
	},

	-- LSP
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "hrsh7th/cmp-nvim-lsp" },
		config = function()
			require("lsp-config")
		end,
	},

	-- 补全：进入插入模式加载，不再限制文件类型
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
		},
		config = function()
			require("cmp-config")
		end,
	},

	-- 格式化（启动即加载，保证第一次保存就会格式化）
	{
		"stevearc/conform.nvim",
		lazy = false,
		cmd = { "ConformInfo" },
		config = function()
			require("formatter")
		end,
	},

	-- 括号补全
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("autopairs-config")
		end,
	},

	-- git 提示
	{ "lewis6991/gitsigns.nvim", event = { "BufReadPre", "BufNewFile" }, opts = {} },

	-- telescope（键位放在 keys 里，按需加载且键位不变）
	{
		"nvim-telescope/telescope.nvim",
		version = "*",
		cmd = "Telescope",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			-- 需要 make / clang，Termux 上装不上可注释掉这行
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
		keys = {
			{
				"<leader>ff",
				function()
					require("telescope.builtin").find_files()
				end,
				desc = "查找文件",
			},
			{
				"<leader>fg",
				function()
					require("telescope.builtin").live_grep()
				end,
				desc = "实时搜索",
			},
			{
				"<leader>fb",
				function()
					require("telescope.builtin").buffers()
				end,
				desc = "查看缓冲区",
			},
			{
				"<leader>fh",
				function()
					require("telescope.builtin").help_tags()
				end,
				desc = "帮助标签",
			},
		},
		config = function()
			require("telescope-config")
		end,
	},

	-- 翻译
	{
		"noir4y/comment-translate.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("comment-translate-config")
		end,
	},

	-- codecompanion.nvim（命令 / 快捷键触发加载）
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions", "CodeCompanionCmd" },
		keys = {
			{
				"<leader>ac",
				"<cmd>CodeCompanionChat Toggle<cr>",
				mode = { "n", "v" },
				desc = "打开/关闭 AI 对话",
			},
			{ "<leader>ai", "<cmd>CodeCompanion<cr>", mode = { "n", "v" }, desc = "内联生成代码" },
			{ "<leader>aa", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI 动作菜单" },
			{ "<leader>av", ":CodeCompanion ", mode = "v", desc = "对选中代码提问" },
		},
		config = function()
			-- 兜底：即使自定义配置出错，也要保证 AI 窗口能打开
			local ok, err = pcall(require, "CodeCompanion-config")
			if not ok then
				vim.notify(
					("[CodeCompanion] 配置加载失败，已回退默认配置：\n%s"):format(err),
					vim.log.levels.ERROR,
					{ title = "CodeCompanion" }
				)
				pcall(function()
					require("codecompanion").setup({})
				end)
			end
		end,
	},
}
