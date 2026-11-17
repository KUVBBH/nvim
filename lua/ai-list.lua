-- ~/.config/nvim/lua/llm-config.lua

local configs = {
	comment = {
		zhipu = {
			provider = "openai",
			endpoint = "https://open.bigmodel.cn/api/paas/v4/chat/completions",
			model = "glm-4-flash",
			api_key = vim.env.ZHIPU_API_KEY or "你的默认智谱Key",
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
			model = "deepseek-flash",
			api_key = vim.env.DEEPSEEK_API_KEY,
		},
	},
}

return configs
