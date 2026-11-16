-- ~/.config/nvim/lua/llm-config.lua

local configs = {
	-- 配置 1：智谱 GLM
	zhipu = {
		provider = "openai",
		endpoint = "https://open.bigmodel.cn/api/paas/v4/chat/completions",
		model = "glm-4-flash",
		api_key = vim.env.ZHIPU_API_KEY or "你的默认智谱Key",
		timeout = 60,
	},

	-- 配置 2：DeepSeek
	deepseek = {
		provider = "openai",
		endpoint = "https://api.deepseek.com/v1/chat/completions",
		model = "deepseek-chat",
		api_key = vim.env.DEEPSEEK_API_KEY or "你的默认DeepSeekKey",
		timeout = 60,
	},

	-- 配置 3：本地 Ollama 或其它 OpenAI 兼容接口
	local_llm = {
		provider = "openai",
		endpoint = "http://localhost:11434/v1/chat/completions",
		model = "qwen2.5-coder",
		api_key = "ollama", -- 本地通常不需要 key
		timeout = 120,
	},
}

-- 🌟 在这里决定当前使用哪套配置
-- 你也可以通过环境变量来动态切换：export NVIM_LLM_PROVIDER="deepseek"
-- local active_provider = vim.env.NVIM_LLM_PROVIDER or "zhipu"

-- 返回选中的配置表
return configs
