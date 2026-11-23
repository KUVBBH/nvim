-- ~/.config/nvim/lua/ai-list.lua
-- LLM endpoint / api_key / model 的单一数据源
-- 模型名以官方为准：deepseek-chat / deepseek-reasoner

local configs = {
	comment = {
		zhipu = {
			provider = "openai",
			endpoint = "https://open.bigmodel.cn/api/paas/v4/chat/completions",
			model = "glm-4-flash",
			api_key = vim.env.ZHIPU_API_KEY,
			timeout = 60,
		},
		deepseek = {
			provider = "openai",
			endpoint = "https://api.deepseek.com/chat/completions",
			model = "deepseek-chat",
			-- 兼容两种变量名，避免换机器后翻译静默失败
			api_key = vim.env.DEEPSEEK_API_KEY_FANYI or vim.env.DEEPSEEK_API_KEY,
			timeout = 60,
		},
	},

	codecompanion = {
		zhipu = {
			endpoint = "https://open.bigmodel.cn/api/paas/v4",
			model = "glm-4-flash",
			api_key = vim.env.ZHIPU_API_KEY,
		},
		deepseek = {
			endpoint = "https://api.deepseek.com",
			model = "deepseek-chat",
			api_key = vim.env.DEEPSEEK_API_KEY,
		},
	},
}

return configs
