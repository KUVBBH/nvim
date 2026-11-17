-- ~/.config/nvim/lua/codecompanion-config.lua

local MODEL = "deepseek"

vim.api.nvim_create_autocmd("User", {
	pattern = "VeryLazy",
	callback = function()
		local ok, codecompanion = pcall(require, "codecompanion")
		if not ok then
			vim.notify("codecompanion.nvim 未加载", vim.log.levels.WARN)
			return
		end

		local config = require("ai-list").codecompanion[MODEL]
		if not config or not config.endpoint then
			vim.notify(("未在 ai-list 中找到有效的 %s 配置"):format(MODEL), vim.log.levels.ERROR)
			return
		end

		codecompanion.setup({
			log_level = "DEBUG",
			rules = require("ai-rules"),

			strategies = {
				chat = { adapter = MODEL },
				inline = { adapter = MODEL },
			},

			adapters = {
				http = {
					[MODEL] = function()
						return require("codecompanion.adapters").extend("openai_compatible", {
							formatted_name = MODEL,
							url = "${url}/chat/completions",
							env = {
								url = config.endpoint,
								api_key = config.api_key,
							},
							schema = {
								model = {
									default = config.model,
									choices = { [config.model] = { opts = {} } },
								},
							},
							handlers = {
								form_parameters = function(self, params, messages)
									params.model = self.schema.model.default

									local cleaned = {}
									for _, msg in ipairs(messages or {}) do
										if msg.content and msg.content ~= "" then
											table.insert(cleaned, msg)
										end
									end

									params.messages = (#cleaned > 0) and cleaned
										or { { role = "user", content = "hi" } }
									return params
								end,
							},
						})
					end,
				},
			},

			display = {
				chat = {
					window = {
						layout = "float",
						width = 0.9,
						height = 0.85,
						border = "rounded",
					},
				},
			},
		})

		local map = vim.keymap.set
		map({ "n", "v" }, "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "打开/关闭 AI 对话" })
		map({ "n", "v" }, "<leader>ai", "<cmd>CodeCompanion<cr>", { desc = "内联生成代码" })
		map({ "n", "v" }, "<leader>aa", "<cmd>CodeCompanionActions<cr>", { desc = "AI 动作菜单" })
		map("v", "<leader>av", ":CodeCompanion ", { desc = "对选中代码提问" })
	end,
})
