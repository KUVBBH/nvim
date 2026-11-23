local MODEL = "deepseek" -- 切回智谱就改成 "zhipu"

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
			opts = {
				language = "Chinese",
				log_level = "WARN",
			},

			rules = {
				opts = {
					chat = {
						autoload = { "default", "basic_rules" },
					},
				},
				["basic_rules"] = {
					description = "中文编程与项目规范",
					files = {},
				},
			},

			interactions = {
				chat = {
					adapter = MODEL,
					opts = {
						system_prompt = function(ctx)
							local rules_dir = vim.fn.stdpath("config") .. "/rules/基础规则"
							local pattern = rules_dir .. "/**/*.md*"
							local files = vim.fn.glob(pattern, false, true)

							table.sort(files)

							local parts = {}
							for _, path in ipairs(files) do
								local file = io.open(path, "r")
								if file then
									local name = vim.fn.fnamemodify(path, ":t")
									table.insert(parts, "--- " .. name .. " ---\n" .. file:read("*a"))
									file:close()
								end
							end

							-- 1. 最核心的强制规则，放在最前面，防止被默认提示词稀释
							local force_rule =
								"【CRITICAL INSTRUCTION - HIGHEST PRIORITY】：无论任务复杂程度如何（包括编写长代码），你的每一条回复都必须以【📋 任务进度】报告开头（包含已完成、待办、当前状态）。如果你忽略此规则，直接输出代码或思考，将被视为回复失败，必须严格无条件执行！\n\n"

							local custom = ""
							if #parts == 0 then
								vim.notify(
									"[CodeCompanion] 未在 "
										.. rules_dir
										.. " 中找到任何 .md 规则文件，仅使用强制规则与默认提示词",
									vim.log.levels.WARN
								)
							else
								vim.notify(
									"[CodeCompanion] 已加载 " .. #parts .. " 个规则文件",
									vim.log.levels.INFO
								)
								custom = table.concat(parts, "\n\n") .. "\n\n"
							end

							-- 环境信息放在最后
							local env = "\n\n## Environment\n- OS: "
								.. ctx.os
								.. "\n- Neovim: "
								.. ctx.nvim_version
								.. "\n- Date: "
								.. ctx.date
								.. "\n- CWD: "
								.. ctx.cwd
								.. "\n- Project: "
								.. (ctx.project_root or "none")
								.. "\n- Adapter: "
								.. (ctx.adapter and ctx.adapter.name or "unknown")
								.. "\n- Lang: "
								.. ctx.language

							return force_rule .. custom .. ctx.default_system_prompt .. env
						end,
					},

					tools = {
						opts = {
							system_prompt = {
								enabled = true,
							},
						},
					},
				},

				inline = {
					adapter = MODEL,
				},

				shared = {},
			},

			adapters = {
				http = {
					zhipu = function()
						local zc = require("ai-list").codecompanion.zhipu
						return require("codecompanion.adapters").extend("openai_compatible", {
							formatted_name = "Zhipu GLM",
							url = "${url}/chat/completions",
							env = {
								url = zc.endpoint,
								api_key = zc.api_key,
							},
							schema = {
								model = {
									default = zc.model,
									choices = {
										[zc.model] = { opts = {} },
									},
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

					deepseek = function()
						local dc = require("ai-list").codecompanion.deepseek
						return require("codecompanion.adapters").extend("deepseek", {
							formatted_name = "DeepSeek",
							url = "${url}/chat/completions",
							env = {
								url = dc.endpoint,
								api_key = dc.api_key,
							},
							schema = {
								model = {
									default = dc.model,
									choices = {
										[dc.model] = { opts = {} },
									},
								},
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

			prompt_library = {
				["中文解释代码"] = {
					strategy = "chat",
					description = "用中文解释选中的代码",
					opts = {
						index = 1,
						is_default = true,
						is_slash_cmd = false,
						modes = { "v" },
						short_name = "explain_cn",
						auto_submit = true,
						user_prompt = false,
						stop_context_insertion = true,
					},
					prompts = {
						{
							role = "system",
							content = [[当被要求解释代码时，请遵循以下步骤:]],
							opts = { visible = false },
						},
						{
							role = "user",
							content = function(context)
								local input = require("codecompanion.helpers.actions").get_code(
									context.start_line,
									context.end_line
								)
								return string.format(
									"请解释 buffer %d 中的这段代码:\n```%s\n%s\n```",
									context.bufnr,
									context.filetype,
									input
								)
							end,
							opts = { contains_code = true },
						},
					},
				},

				["中文修复代码"] = {
					strategy = "chat",
					description = "用中文分析并修复选中的代码问题",
					opts = {
						index = 2,
						is_default = true,
						is_slash_cmd = false,
						modes = { "v" },
						short_name = "fix_cn",
						auto_submit = true,
						user_prompt = false,
						stop_context_insertion = true,
					},
					prompts = {
						{
							role = "system",
							content = "你是一个代码审查专家。分析代码中的问题，用中文解释问题原因，然后提供修复后的完整代码。",
							opts = { visible = false },
						},
						{
							role = "user",
							content = function(context)
								local input = require("codecompanion.helpers.actions").get_code(
									context.start_line,
									context.end_line
								)
								return string.format(
									"请分析并修复以下代码中的问题:\n```%s\n%s\n```",
									context.filetype,
									input
								)
							end,
							opts = { contains_code = true },
						},
					},
				},
			},

			extensions = {},
		})

		local map = vim.keymap.set

		map({ "n", "v" }, "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", {
			desc = "打开/关闭 AI 对话",
			noremap = true,
			silent = true,
		})

		map({ "n", "v" }, "<leader>ai", "<cmd>CodeCompanion<cr>", {
			desc = "内联生成代码",
			noremap = true,
			silent = true,
		})

		map({ "n", "v" }, "<leader>aa", "<cmd>CodeCompanionActions<cr>", {
			desc = "AI 动作菜单",
			noremap = true,
			silent = true,
		})

		map("v", "<leader>av", ":CodeCompanion ", {
			desc = "对选中代码提问",
		})
	end,
})
