local MODEL = "deepseek"

-- ⚠️ 注意这里：全部改成小写 CodeCompanion-config
local build_system_prompt = require("CodeCompanion-config.rules").build_system_prompt
local http_adapters = require("CodeCompanion-config.adapters").http
local prompt_library = require("CodeCompanion-config.prompts").library

vim.api.nvim_create_autocmd("User", {
	pattern = "VeryLazy",
	callback = function()
		local ok, codecompanion = pcall(require, "codecompanion")
		if not ok then
			return
		end

		local cfg = require("ai-list").codecompanion[MODEL]
		if not cfg or not cfg.endpoint then
			return
		end

		-- 1. 初始化规则表
		local rules_table = {
			opts = {
				chat = {
					autoload = { "default", "basic_rules" },
				},
			},
			["basic_rules"] = {
				description = "中文编程与项目规范",
				files = {},
			},
		}

		-- 2. 动态扫描（注意这里路径改成了 基础规则）
		local rules_dir = vim.fn.stdpath("config") .. "/rules/基础规则"
		local files = vim.fn.glob(rules_dir .. "/*.md*", false, true)

		local file_names = {} -- 用来记录名字
		for _, path in ipairs(files) do
			local rule_name = vim.fn.fnamemodify(path, ":t:r")
			table.insert(file_names, rule_name)

			rules_table[rule_name] = {
				description = "自定义规则: " .. rule_name,
				files = { path },
			}
		end

		-- 这里会把扫描到的规则名字打印出来
		-- if #file_names > 0 then
		-- 	vim.print("[CodeCompanion] 成功加载以下规则: " .. table.concat(file_names, ", "))
		-- end

		codecompanion.setup({
			opts = { language = "Chinese", log_level = "WARN" },
			rules = rules_table,
			interactions = {
				chat = {
					adapter = MODEL,
					opts = { system_prompt = build_system_prompt },
					tools = { opts = { system_prompt = { enabled = true } } },
				},
				inline = { adapter = MODEL },
				shared = {},
			},
			adapters = { http = http_adapters },
			display = {
				chat = {
					window = { layout = "float", width = 0.9, height = 0.85, border = "rounded" },
					intro_message = #file_names > 0
							and "已加载规则 :\n" .. table.concat(file_names, ",\n") .. "\n"
						or "Welcome to CodeCompanion! Press ? for options",
				},
			},
			prompt_library = prompt_library,
			extensions = {},
		})

		local function map(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { desc = desc, noremap = true, silent = true })
		end
		map({ "n", "v" }, "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", "打开/关闭 AI 对话")
		map({ "n", "v" }, "<leader>ai", "<cmd>CodeCompanion<cr>", "内联生成代码")
		map({ "n", "v" }, "<leader>aa", "<cmd>CodeCompanionActions<cr>", "AI 动作菜单")
		map("v", "<leader>av", ":CodeCompanion ", "对选中代码提问")
	end,
})
