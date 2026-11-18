-- =============================================================================
-- codecompanion.nvim 完整配置文件
-- 基于官方文档（2026-11 版本），所有官方支持的配置项均已列出
-- 注释写在配置项上方，带 FIX 标记的是你原来配置里需要修正的关键点
-- =============================================================================

-- 当前使用的模型标识，切换模型只改这一行
local MODEL = "deepseek" -- 切回智谱就改成 "zhipu"

vim.api.nvim_create_autocmd("User", {
	pattern = "VeryLazy",
	callback = function()
		local ok, codecompanion = pcall(require, "codecompanion")
		if not ok then
			vim.notify("codecompanion.nvim 未加载", vim.log.levels.WARN)
			return
		end

		-- 从你的 ai-list 模块读取 API 配置（endpoint / api_key / model）
		local config = require("ai-list").codecompanion[MODEL]
		if not config or not config.endpoint then
			vim.notify(("未在 ai-list 中找到有效的 %s 配置"):format(MODEL), vim.log.levels.ERROR)
			return
		end

		codecompanion.setup({
			-- =========================================================================
			-- 一、全局选项（opts）
			-- 控制插件的全局行为，如语言、日志级别等
			-- =========================================================================
			opts = {
				-- 插件的回复语言，所有非代码文本都会用这个语言输出
				-- 可选值: "English"（默认）、"Chinese"、"Japanese" 等
				language = "Chinese",

				-- 日志级别，排查问题时设为 "DEBUG" 或 "TRACE"
				-- 可选值: "ERROR"、"WARN"、"INFO"、"DEBUG"、"TRACE"
				-- 日志文件位于: ~/.local/state/nvim/codecompanion.log
				log_level = "WARN",

				-- 日期格式，用于 system prompt 中的 ${date} 变量
				-- 默认值: "%A, %d %B %Y"
				-- date_format = "%Y-%m-%d",
			},

			-- =========================================================================
			-- 二、规则系统（rules）
			-- 规则是持久化的指令文件（如 CLAUDE.md、AGENTS.md），
			-- 每次新对话时自动注入，让 LLM 记住项目约定
			-- =========================================================================
			rules = {
				-- FIX: autoload 必须放在 rules.opts.chat 下面，
				-- 不能放在 setup 顶层的 opts 里，插件读不到
				opts = {
					chat = {
						-- 自动加载的规则组列表，每个新聊天缓冲区都会注入这些规则
						-- "default" 是内置组，会自动读取 CLAUDE.md / AGENTS.md 等文件
						-- "basic_rules" 是下面定义的自定义规则组
						autoload = { "default", "basic_rules" },

						-- 是否启用规则系统（默认 true）
						-- enabled = true,

						-- 是否在 /rules 斜杠命令和 Actions 菜单中显示内置规则组
						-- show_presets = false,

						-- 引用文件的同步方式: "all" 发送完整内容, "diff" 只发送变化部分
						-- default_params = "all",

						-- 是否在 prompt_library 条目中也自动加载 autoload 规则
						-- autoload_groups_in_prompt_library = true,
					},
				},

				-- FIX: 自定义规则组的正确定义方式
				-- 格式: rules[组名] = { description, files, parser?, enabled? }
				-- 组名就是 autoload 列表里引用的名字
				-- 注意: 组名建议用英文，避免中文在部分环境下出现编码问题
				["basic_rules"] = {
					description = "中文编程与项目规范",
					files = {
						-- 在这里添加你的规则文件路径
						-- 支持: 绝对路径、相对路径（相对于 cwd）、glob 模式
						-- 示例:
						-- "CLAUDE.md",
						-- "~/.config/nvim/rules/basic.md",
						-- "docs/**/*.md",
						-- { path = "SPECIAL.md", parser = "claude" },
					},
					-- 可选: 使用指定解析器处理规则文件
					-- 内置解析器: "claude"（支持 @ 引用）、"codecompanion"（按 ## 标题分段）、"none"（原样）
					-- parser = "none",

					-- 可选: 条件启用，返回 false 时该规则组不会出现在菜单中
					-- enabled = function()
					--     return vim.fn.getcwd():find("my_project") ~= nil
					-- end,
				},

				-- =========================================================================
				-- 内置 "default" 规则组会自动查找以下文件（不存在则跳过）：
				--   .clinerules        → Cline
				--   .cursorrules       → Cursor
				--   .goosehints         → Goose
				--   .rules              → Zed
				--   .windsurfrules      → Windsurf
				--   .github/copilot-instructions.md → Copilot
				--   AGENT.md / AGENTS.md → Agents
				--   CLAUDE.md           → Claude Code
				--   CLAUDE.local.md     → Claude Code
				--   ~/.claude/CLAUDE.md → Claude Code
				-- =========================================================================
			},

			-- =========================================================================
			-- 三、交互配置（interactions）
			-- FIX: 你原来用的 "strategies" 在新版中已被 "interactions" 替代
			-- 这是配置 adapter 和 system_prompt 的正确位置
			-- =========================================================================
			interactions = {
				-- --- 聊天模式（Chat Buffer）配置 ---
				chat = {
					-- 聊天模式使用的适配器名称，对应下面 adapters 里定义的 key
					adapter = MODEL,

					-- 聊天模式的详细选项
					opts = {
						-- FIX: system_prompt 放在这里，不是 strategies.chat.roles.llm
						-- 这会完全替换默认的 system prompt
						-- 支持字符串或函数: function(ctx) return "..." end
						-- ctx 包含: adapter, cwd, date, default_system_prompt,
						--           language, nvim_version, os, project_root
						--
						-- 注意: Lua 字符串中不要混用中文引号，会被解析器打断
						system_prompt = function(ctx)
							-- 你的规则文件夹路径，改成你自己的
							local rules_dir = vim.fn.stdpath("config") .. "/rules/基础规则"

							-- 扫描目录下所有 .md 文件（** 表示递归子目录）
							local pattern = rules_dir .. "/**/*.md*"
							local files = vim.fn.glob(pattern, false, true)

							-- 按文件名排序，保证加载顺序稳定
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

							-- 没读到任何文件，给提示并回退到默认提示词
							if #parts == 0 then
								vim.notify(
									"[CodeCompanion] 未在 "
										.. rules_dir
										.. " 中找到任何 .md 规则文件，已使用默认提示词",
									vim.log.levels.WARN
								)
								return ctx.default_system_prompt
							end

							-- 成功加载时也提示一下加载了哪些文件（可选，不想要就删掉这段）
							vim.notify(
								"[CodeCompanion] 已加载 " .. #parts .. " 个规则文件",
								vim.log.levels.INFO
							)

							local custom = table.concat(parts, "\n\n")
							return ctx.default_system_prompt .. "\n\n" .. custom
						end,
						-- 如果你想保留默认提示词并追加内容，用函数形式:
						-- system_prompt = function(ctx)
						--     return ctx.default_system_prompt
						--         .. "\n\n额外规则：所有回复使用简体中文。"
						-- end,
					},

					-- --- 工具系统（tools）配置 ---
					-- 当 LLM 使用 @{files} 等工具时生效
					tools = {
						opts = {
							-- 工具专用的 system prompt，追加在主 system prompt 之后
							system_prompt = {
								-- 是否启用工具 system prompt（默认 true）
								enabled = true,
								-- 是否替换主 system prompt 而不是追加（默认 false）
								-- replace_main_system_prompt = false,
							},
						},
					},

					-- --- 斜杠命令（slash_commands）---
					-- 在聊天缓冲区输入 / 触发的命令列表
					-- 内置命令包括: /buffer, /commit, /explain, /fix, /lsp 等
					-- 可以添加自定义斜杠命令:
					-- slash_commands = {
					--     ["my_cmd"] = require("path.to.my_command"),
					-- },

					-- --- 编辑器上下文（editor_context）---
					-- 在聊天消息中用 #{xxx} 语法注入 Neovim 上下文
					-- 内置上下文: #{buffer}, #{diagnostics}/#{lsp}, #{selection},
					--              #{viewport}, #{terminal}, #{code_review}
					-- 可以添加自定义上下文:
					-- editor_context = {
					--     ["my_context"] = { ... },
					-- },

					-- --- 变量（variables）---
					-- 聊天缓冲区中通过 # 补全使用的变量
					-- 内置变量自动可用，无需配置

					-- --- 代码审查（code_review）---
					-- 控制 :CodeCompanionCodeReview 的行为
					-- code_review = { ... },
				},

				-- --- 内联模式（Inline）配置 ---
				-- 选中代码后运行 :CodeCompanion 进行原地编辑
				inline = {
					-- 内联模式使用的适配器
					adapter = MODEL,
				},

				-- --- 共享配置（shared）---
				-- 所有交互模式共用的配置
				shared = {
					-- 自定义编辑器上下文，所有交互模式可用
					-- editor_context = {
					--     ["my_ctx"] = { ... },
					-- },
				},
			},

			-- =========================================================================
			-- 四、适配器（adapters）
			-- 定义连接不同 LLM 服务的方式
			-- 分为 http（API 调用）和 acp（Agent Client Protocol）两类
			-- =========================================================================
			adapters = {
				-- --- HTTP 适配器（通过 REST API 调用）---
				http = {
					-- 智谱 GLM 适配器
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
							-- 自定义请求参数处理
							handlers = {
								form_parameters = function(self, params, messages)
									params.model = self.schema.model.default
									-- 过滤掉空消息，避免 API 报错
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
							-- 可选: 请求头自定义
							-- headers = {
							--     ["Content-Type"] = "application/json",
							-- },
						})
					end,

					-- DeepSeek 适配器
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

					-- =========================================================================
					-- 其他可选的内置适配器（按需取消注释）
					-- =========================================================================

					-- OpenAI（需要 OPENAI_API_KEY 环境变量）
					-- openai = function()
					--     return require("codecompanion.adapters").extend("openai", {
					--         env = { api_key = "OPENAI_API_KEY" },
					--         schema = {
					--             model = {
					--                 default = "gpt-4o",
					--                 choices = { "gpt-4o", "gpt-4o-mini", "gpt-4.1" },
					--             },
					--         },
					--     })
					-- end,

					-- Anthropic Claude（需要 ANTHROPIC_API_KEY 环境变量）
					-- anthropic = function()
					--     return require("codecompanion.adapters").extend("anthropic", {
					--         env = { api_key = "ANTHROPIC_API_KEY" },
					--         schema = {
					--             model = {
					--                 default = "claude-sonnet-4-20250514",
					--                 choices = {
					--                     "claude-sonnet-4-20250514",
					--                     "claude-3-5-haiku-20241022",
					--                 },
					--             },
					--         },
					--     })
					-- end,

					-- Gemini（需要 GEMINI_API_KEY 环境变量）
					-- gemini = function()
					--     return require("codecompanion.adapters").extend("gemini", {
					--         env = { api_key = "GEMINI_API_KEY" },
					--     })
					-- end,

					-- Ollama 本地模型（需要本地运行 Ollama 服务）
					-- ollama = function()
					--     return require("codecompanion.adapters").extend("ollama", {
					--         env = { url = "http://localhost:11434" },
					--         schema = {
					--             model = {
					--                 default = "qwen3:8b",
					--                 choices = {
					--                     ["qwen3:8b"] = { nice_name = "Qwen3 8B" },
					--                     ["deepseek-coder:6.7b"] = { nice_name = "DeepSeek Coder" },
					--                 },
					--             },
					--         },
					--     })
					-- end,
				},

				-- --- ACP 适配器（Agent Client Protocol，连接本地 AI Agent）---
				-- 支持的 Agent: claude_code, codex, gemini_cli, goose,
				--              kimi_cli, cline_cli, cagent, opencode 等
				-- acp = {
				--     claude_code = function()
				--         return require("codecompanion.adapters").extend("claude_code", {
				--             commands = {
				--                 default = { "claude", "--acp" },
				--             },
				--         })
				--     end,
				-- },
			},

			-- =========================================================================
			-- 五、显示配置（display）
			-- 控制聊天窗口、内联 diff 等的显示方式
			-- =========================================================================
			display = {
				-- --- 聊天窗口配置 ---
				chat = {
					-- 聊天窗口的布局方式
					-- 可选值: "float"（浮动窗口）、"vertical"（垂直分割）、"horizontal"（水平分割）
					window = {
						layout = "float",
						-- 窗口宽度（浮点数表示屏幕比例，整数表示列数）
						width = 0.9,
						-- 窗口高度（浮点数表示屏幕比例，整数表示行数）
						height = 0.85,
						-- 窗口边框样式
						-- 可选值: "none"、"single"、"double"、"rounded"、"solid"、"shadow"
						border = "rounded",
						-- 浮动窗口位置（仅 layout = "float" 时有效）
						-- 可选值: "center"、"right"、"left"、"top"、"bottom"
						-- position = "center",
					},

					-- --- 聊天缓冲区显示选项 ---
					-- icons = {
					--     sent = " ",     -- 用户消息图标
					--     error = " ",    -- 错误图标
					--     pinned = " ",   -- 固定上下文图标
					-- },
					-- separators = {
					--     horizontal = "-", -- 消息分隔线字符
					-- },

					-- --- Diff 显示选项 ---
					-- diff = {
					--     enabled = true,
					--     close_chat_at = 0.4, -- 聊天窗口小于此比例时，diff 在浮动窗口显示
					-- },
				},

				-- --- 内联模式 Diff 配置 ---
				-- inline = {
				--     diff = { enabled = true },
				-- },
			},

			-- =========================================================================
			-- 六、提示词库（prompt_library）
			-- 预定义的提示词模板，通过 :CodeCompanionActions 或斜杠命令调用
			-- =========================================================================
			prompt_library = {
				-- --- 自定义中文解释提示词 ---
				["中文解释代码"] = {
					strategy = "chat",
					description = "用中文解释选中的代码",
					opts = {
						index = 1, -- 在 Actions 菜单中的排序位置
						is_default = true, -- 是否出现在默认列表中
						is_slash_cmd = false, -- 是否注册为斜杠命令
						modes = { "v" }, -- 仅在 Visual 模式下可用
						short_name = "explain_cn",
						auto_submit = true, -- 是否自动提交
						user_prompt = false, -- 是否允许用户编辑提示词
						stop_context_insertion = true,
						-- 可以指定使用特定的适配器
						-- adapter = { name = "deepseek", model = "deepseek-chat" },
					},
					prompts = {
						{
							role = "system",
							content = [[当被要求解释代码时，请遵循以下步骤：
1. 识别编程语言。
2. 描述代码的目的，并引用该编程语言的核心概念。
3. 解释每个函数或重要的代码块，包括参数和返回值。
4. 突出说明使用的任何特定函数或方法及其作用。
5. 如果适用，提供该代码如何融入更大应用程序的上下文。]],
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

				-- --- 自定义修复代码提示词 ---
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

				-- =========================================================================
				-- 内置提示词（自动可用，无需配置）:
				--   /explain  - 解释代码
				--   /fix      - 修复代码
				--   /lsp      - 解释 LSP 诊断信息
				--   /commit   - 生成 commit message
				--   /buffer   - 分析当前缓冲区
				-- =========================================================================
			},

			-- =========================================================================
			-- 七、扩展（extensions）
			-- 通过第三方插件扩展 CodeCompanion 的功能
			-- =========================================================================
			extensions = {
				-- MCP Hub 集成（需要安装 ravitemer/mcphub.nvim）
				-- mcphub = {
				--     callback = "mcphub.extensions.codecompanion",
				--     opts = {
				--         make_vars = true,            -- 将 MCP 资源注册为变量
				--         make_slash_commands = true,   -- 将 MCP 提示词注册为斜杠命令
				--         show_result_in_chat = true,   -- 在聊天中显示 MCP 工具调用结果
				--     },
				-- },

				-- 历史记录扩展（需要安装 ravitemer/codecompanion-history.nvim）
				-- history = {
				--     enabled = true,
				--     opts = {
				--         dir = vim.fn.stdpath("data") .. "/codecompanion-history",
				--     },
				-- },
			},
		})

		-- =========================================================================
		-- 八、快捷键绑定
		-- CodeCompanion 不设置任何全局快捷键，需要手动映射
		-- =========================================================================
		local map = vim.keymap.set

		-- 切换聊天窗口（打开/关闭，保持对话历史）
		map({ "n", "v" }, "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", {
			desc = "打开/关闭 AI 对话",
			noremap = true,
			silent = true,
		})

		-- 内联编辑（选中代码后原地修改）
		map({ "n", "v" }, "<leader>ai", "<cmd>CodeCompanion<cr>", {
			desc = "内联生成代码",
			noremap = true,
			silent = true,
		})

		-- 打开 Actions 菜单（浏览所有可用的提示词和命令）
		map({ "n", "v" }, "<leader>aa", "<cmd>CodeCompanionActions<cr>", {
			desc = "AI 动作菜单",
			noremap = true,
			silent = true,
		})

		-- Visual 模式下对选中代码提问
		map("v", "<leader>av", ":CodeCompanion ", {
			desc = "对选中代码提问",
		})

		-- 将选中的代码添加到当前聊天（不提交）
		-- map("v", "ga", "<cmd>CodeCompanionChat Add<cr>", {
		--     desc = "添加选区到聊天",
		--     noremap = true,
		--     silent = true,
		-- })

		-- =========================================================================
		-- 九、聊天缓冲区内的快捷键参考（已内置，无需配置）
		-- =========================================================================
		-- <C-s>          发送消息（Insert 模式）
		-- <CR>           发送消息（Normal 模式）
		-- ga             接受代码变更 / 切换适配器
		-- gr             拒绝代码变更
		-- gv             打开 Diff 浮动窗口
		-- gs             切换 system prompt 显示/隐藏
		-- gd             查看完整消息历史（调试视图）
		-- gD             查看 AI 编辑记录（Super Diff）
		-- gp             固定当前缓冲区为上下文
		-- gw             监视缓冲区（实时同步变更）
		-- gt             切换工具审批模式
		-- g1             始终接受当前工具
		-- g2             本次接受
		-- g3             拒绝并告知原因
		-- g4             取消所有待处理的工具调用
		-- q              取消当前请求
		-- gx             清空聊天记录

		-- =========================================================================
		-- 十、可选：命令缩写（在命令行输入 cc 自动展开为 CodeCompanion）
		-- =========================================================================
		-- vim.cmd([[cab cc CodeCompanion]])

		-- =========================================================================
		-- 十一、可选：事件钩子（监听插件事件做自定义操作）
		-- =========================================================================
		-- vim.api.nvim_create_autocmd("User", {
		--     pattern = "CodeCompanionRequest*",
		--     group = vim.api.nvim_create_augroup("CodeCompanionHooks", {}),
		--     callback = function(request)
		--         if request.match == "CodeCompanionRequestStarted" then
		--             vim.notify("AI 思考中...", vim.log.levels.INFO)
		--         elseif request.match == "CodeCompanionRequestFinished" then
		--             vim.notify("AI 回复完成", vim.log.levels.INFO)
		--         end
		--     end,
		-- })
	end,
})
