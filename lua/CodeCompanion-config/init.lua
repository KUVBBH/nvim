local MODEL = "deepseek"

local rules = require("CodeCompanion-config.rules")
local http_adapters = require("CodeCompanion-config.adapters").http
local prompt_library = require("CodeCompanion-config.prompts").library

local cfg = require("ai-list").codecompanion[MODEL]

if not cfg or not cfg.endpoint then
	vim.notify(
		("未在 ai-list 中找到有效的 %s 配置"):format(MODEL),
		vim.log.levels.ERROR,
		{ title = "CodeCompanion" }
	)
	return
end

if not cfg.api_key then
	vim.notify(
		("环境变量中缺少 %s 的 api_key，请求会失败"):format(MODEL),
		vim.log.levels.WARN,
		{ title = "CodeCompanion" }
	)
end

local rule_table = rules.build_table()
local rule_names = {}
for name in pairs(rule_table) do
	if name ~= "opts" then
		table.insert(rule_names, name)
	end
end
table.sort(rule_names)

require("codecompanion").setup({
	opts = { language = "Chinese", log_level = "WARN" },
	rules = rule_table,
	interactions = {
		chat = {
			adapter = MODEL,
			opts = { system_prompt = rules.build_system_prompt },
			tools = { opts = { system_prompt = { enabled = true } } },
		},
		inline = { adapter = MODEL },
		shared = {},
	},
	adapters = { http = http_adapters },
	display = {
		chat = {
			window = { layout = "float", width = 0.9, height = 0.85, border = "rounded" },
			intro_message = #rule_names > 0 and "已加载规则 :\n" .. table.concat(rule_names, ",\n") .. "\n"
				or "Welcome to CodeCompanion! Press ? for options",
		},
	},
	prompt_library = prompt_library,
	extensions = {},
})

-- 聊天窗口内的 @ / # / 速查浮窗
require("CodeCompanion-help")
