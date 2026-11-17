-- ~/.config/nvim/lua/codecompanion-config.lua

vim.api.nvim_create_autocmd("User", {
	pattern = "VeryLazy",
	callback = function()
		-- 1. 安全引入 codecompanion
		local ok, codecompanion = pcall(require, "codecompanion")
		if not ok then
			vim.notify("codecompanion.nvim 未加载", vim.log.levels.WARN)
			return
		end

		local config = require("ai-list").codecompanion.zhipu

		if not config or not config.endpoint then
			vim.notify("未在 ai-list 中找到有效的 zhipu_codecompanion 配置", vim.log.levels.ERROR)
			return
		end

		-- 3. 执行 setup
		codecompanion.setup({
			log_level = "DEBUG",
			rules = require("ai-rules"),

			strategies = {
				chat = { adapter = "zhipu" },
				inline = { adapter = "zhipu" },
			},

			adapters = {
				http = {
					zhipu = function()
						return require("codecompanion.adapters").extend("openai_compatible", {
							formatted_name = "Zhipu GLM",

							-- 🔴 修复 1：覆盖默认的 /v1/chat/completions 路径
							url = "${url}/chat/completions",

							env = {
								url = config.endpoint, -- 你的 https://open.bigmodel.cn/api/paas/v4
								api_key = config.api_key,
							},

							schema = {
								model = {
									default = config.model,
									-- 🔴 修复 2：强制锁定模型，阻止后台请求 /models 端点
									choices = { [config.model] = { opts = {} } },
								},
							},

							-- 🔴 修复 3：拦截并清洗参数，过滤掉空消息，防止智谱报 1213 错误
							handlers = {
								form_parameters = function(self, params, messages)
									params.model = self.schema.model.default

									-- 过滤掉 content 为空的非法消息
									local cleaned = {}
									for _, msg in ipairs(messages or {}) do
										if msg.content and msg.content ~= "" then
											table.insert(cleaned, msg)
										end
									end

									-- 如果全部为空，塞入一个占位符防止报错
									params.messages = (#cleaned > 0) and cleaned
										or { { role = "user", content = "hi" } }
									return params
								end,
							},
						})
					end,
				},
			},

			-- 🌟 适配手机屏幕：超大浮动窗口
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

		-- 4. 绑定快捷键
		local map = vim.keymap.set
		map({ "n", "v" }, "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "打开/关闭 AI 对话" })
		map({ "n", "v" }, "<leader>ai", "<cmd>CodeCompanion<cr>", { desc = "内联生成代码" })
		map({ "n", "v" }, "<leader>aa", "<cmd>CodeCompanionActions<cr>", { desc = "AI 动作菜单" })
		map("v", "<leader>av", ":CodeCompanion ", { desc = "对选中代码提问" })
	end,
})
