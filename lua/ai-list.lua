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
			api_key = vim.env.DEEPSEEK_API_KEY_FANYI,
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
