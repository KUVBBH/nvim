local M = {}

-- 空消息过滤（zhipu 需要，deepseek 不需要）
local function form_parameters_guard(self, params, messages)
	params.model = self.schema.model.default
	local cleaned = {}
	for _, msg in ipairs(messages or {}) do
		if msg.content and msg.content ~= "" then
			table.insert(cleaned, msg)
		end
	end
	params.messages = (#cleaned > 0) and cleaned or { { role = "user", content = "hi" } }
	return params
end

-- 工厂：base 不同、handlers 可选
local function make_adapter(name, opts)
	return function()
		local cfg = require("ai-list").codecompanion[name]
		local spec = {
			formatted_name = opts.formatted_name,
			url = "${url}/chat/completions",
			env = { url = cfg.endpoint, api_key = cfg.api_key },
			schema = {
				model = {
					default = cfg.model,
					choices = { [cfg.model] = { opts = {} } },
				},
			},
		}
		if opts.handlers then
			spec.handlers = opts.handlers
		end
		return require("codecompanion.adapters").extend(opts.base, spec)
	end
end

M.http = {
	zhipu = make_adapter("zhipu", {
		base = "openai_compatible",
		formatted_name = "Zhipu GLM",
		handlers = { form_parameters = form_parameters_guard },
	}),
	deepseek = make_adapter("deepseek", {
		base = "deepseek",
		formatted_name = "DeepSeek",
	}),
}

return M
