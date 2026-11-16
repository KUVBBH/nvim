require("comment-translate").setup({
	target_language = "zh", -- 翻译目标语言
	translate_service = "llm", -- 翻译引擎：使用大语言模型

	-- 自动悬浮翻译配置
	hover = {
		enabled = true, -- 开启悬浮窗功能
		delay = 1500, -- 停留 500 毫秒后触发
		auto = true, -- 开启自动触发
	},

	-- 缓存配置
	cache = {
		enabled = true,
		max_entries = 2000,
	},

	-- 快捷键配置
	keymaps = {
		hover = false, -- 禁用快捷键触发的悬浮（因为上面开了 auto）
		hover_manual = false, -- 禁用手动触发
		replace = "<leader>tr", -- 保留：可视模式下选中替换
		toggle = "<leader>tt", -- 保留：行内沉浸式翻译
	},

	-- 大模型 (LLM) 接口配置
	llm = vim.g.ai_list["zhipu_comment"],
})
