-- 获取字符实际显示宽度
local function get_display_width(str)
	return vim.fn.strdisplaywidth(str)
end

-- 计算填充空格以实现完美对齐
local function pad_str(str, target_width)
	local width = get_display_width(str)
	if width >= target_width then
		return str
	end
	return str .. string.rep(" ", target_width - width)
end

-- 解析反引号，生成高亮位置
local function parse_highlights(line_str)
	local parsed = ""
	local highlights = {}
	local i = 1
	local len = #line_str

	while i <= len do
		local start_idx, end_idx = line_str:find("`[^`]*`", i)
		if not start_idx then
			parsed = parsed .. line_str:sub(i)
			break
		end

		parsed = parsed .. line_str:sub(i, start_idx - 1)
		local content = line_str:sub(start_idx + 1, end_idx - 1)
		local col_start = #parsed
		parsed = parsed .. content
		local col_end = #parsed

		local group = "Identifier"
		if content:match("^[@#/]") then
			group = "Function"
		elseif content:match("%.") or content:match("/") then
			group = "Directory"
		end

		table.insert(highlights, { start_col = col_start, end_col = col_end, group = group })
		i = end_idx + 1
	end

	return parsed, highlights
end

local function build_group(title, items)
	return { title = title, items = items }
end

-- 数据部分：工具列表
local data_tools = {
	build_group("【核心文件操作】", {
		{
			cmd = "@read_file",
			desc = "📖 读取文件内容",
			note = "让 AI 看到指定文件的完整源码，用于分析、解释或作为修改依据",
			ex = "`@read_file` 解释 `src/main.lua` 的逻辑",
		},
		{
			cmd = "@edit_file",
			desc = "✏️ 局部编辑代码",
			note = "精确替换文件中的某段代码，不动其他部分，适合小范围修改",
			ex = "`@edit_file` 将同步调用替换为 `async/await`",
		},
		{
			cmd = "@overwrite_file",
			desc = "📝 覆盖写入整个文件",
			note = "用 AI 生成的内容完全替换文件，适合重写或大改整个文件",
			ex = "`@overwrite_file` 用函数式组件重写 `App.vue`",
		},
		{
			cmd = "@create_file",
			desc = "📄 创建新文件",
			note = "在项目中创建一个不存在的文件并写入内容",
			ex = "`@create_file` 创建 `config.json` 填入默认配置",
		},
		{
			cmd = "@delete_file",
			desc = "🗑️ 删除文件",
			note = "从项目中永久删除指定文件",
			ex = "`@delete_file` 删除无用的 `legacy_test.js`",
		},
	}),
	build_group("【检索与运行】", {
		{
			cmd = "@grep_search",
			desc = "🔍 全局关键字/正则搜索",
			note = "在整个项目中搜索文本或正则，返回匹配的文件和行号",
			ex = "`@grep_search` 查找所有用到 `'useEffect'` 的地方",
		},
		{
			cmd = "@file_search",
			desc = "🔎 按文件名查找",
			note = "按文件名或路径片段模糊搜索，快速定位文件位置",
			ex = "`@file_search` 找到 `utils.ts` 的位置",
		},
		{
			cmd = "@run_command",
			desc = "💻 执行终端命令",
			note = "在终端运行命令并返回结果，可以跑测试、装依赖、构建项目等",
			ex = "`@run_command` 运行 `npm run test` 并修复报错",
		},
		{
			cmd = "@get_changed_files",
			desc = "📋 获取已更改文件列表",
			note = "列出本次会话中所有被修改过的文件，方便回顾改动范围",
			ex = "`@get_changed_files` 总结我今天改了哪些文件",
		},
		{
			cmd = "@get_diagnostics",
			desc = "🚨 获取 LSP 报错信息",
			note = "读取语言服务器报告的错误和警告，让 AI 针对性修复",
			ex = "`@get_diagnostics` 修复当前的警告",
		},
		{
			cmd = "@search_help",
			desc = "❓ 检索 Vim 帮助文档",
			note = "搜索 Neovim 内置帮助文档，查询函数用法、配置选项等",
			ex = "`@search_help` 查一下 `os.date` 怎么用",
		},
	}),
	build_group("【网络与代理】", {
		{
			cmd = "@web_search",
			desc = "🌐 联网搜索",
			note = "通过搜索引擎查找最新信息，适合查文档、API 变更、解决方案等",
			ex = "`@web_search` 搜索 `Neovim 0.10` 的破坏性更新",
		},
		{
			cmd = "@fetch_webpage",
			desc = "🕸️ 抓取网页正文",
			note = "获取指定 URL 的页面内容并转为可读文本，用于阅读文档或文章",
			ex = "`@fetch_webpage` 抓取并总结 `https://example.com`",
		},
		{
			cmd = "@memory",
			desc = "🧠 读取项目规范记忆",
			note = "加载项目中的规范文件，让 AI 遵循团队约定和编码习惯",
			ex = "`@memory` 读取 `AGENTS.md` 并遵循项目规范",
		},
		{
			cmd = "@ask_questions",
			desc = "❓ 向用户提问",
			note = "AI 在执行前最多问你 4 个澄清问题，需求模糊时自动触发",
			ex = "`@{agent}` 帮我重构认证模块",
		},
	}),
	build_group("【工具组（一键授权多个工具）】", {
		{
			cmd = "@{agent}",
			desc = "🤖 完整代理模式",
			note = "授予全部工具权限并启用专属 system prompt，AI 自主规划并执行多步复杂任务",
			ex = "`@{agent}` 帮我用 Vue 写一个 Todo 应用",
		},
		{
			cmd = "@{files}",
			desc = "📁 文件操作组",
			note = "授予读写创建删除文件的权限，适合涉及文件修改的任务，不含终端执行",
			ex = "`@{files}` 生成一个 Python 包的目录结构",
		},
	}),
}

-- 数据部分：上下文变量
local data_context = {
	build_group("【缓冲区与代码视图】", {
		{
			cmd = "#{buffer}",
			desc = "📄 当前缓冲区",
			note = "把当前正在编辑的文件内容注入对话，让 AI 看到你正在写的代码",
			ex = "逐步解释 `#{buffer}` 里的逻辑",
		},
		{
			cmd = "#{buffer:main.lua}",
			desc = "📄 指定具体文件的缓冲区",
			note = "把项目中任意一个文件的内容注入对话，不限于当前打开的文件",
			ex = "重构 `#{buffer:utils.ts}` 的代码",
		},
		{
			cmd = "#{buffers}",
			desc = "📚 所有已打开缓冲区",
			note = "把所有已打开的文件内容一起注入，适合跨文件分析",
			ex = "对比 `#{buffers}` 里的实现差异",
		},
		{
			cmd = "#{selection}",
			desc = "✂️ 视觉模式选中的代码",
			note = "只注入你用 Visual 模式高亮选中的那部分代码",
			ex = "把 `#{selection}` 封装成一个函数",
		},
		{
			cmd = "#{viewport}",
			desc = "👁️ 当前窗口可见代码",
			note = "注入当前屏幕上能看到的代码区域，不包括滚动隐藏的部分",
			ex = "解释屏幕上显示的 `#{viewport}` 代码",
		},
	}),
	build_group("【诊断与调试】", {
		{
			cmd = "#{diagnostics}",
			desc = "🚨 当前文件的 LSP 报错",
			note = "注入语言服务器报告的所有错误和警告信息",
			ex = "修复 `#{diagnostics}` 里的报错",
		},
		{
			cmd = "#{quickfix}",
			desc = "📋 Quickfix 列表条目",
			note = "注入 Quickfix 列表中的所有条目，通常是搜索结果或编译错误",
			ex = "批量修复 `#{quickfix}` 里的问题",
		},
		{
			cmd = "#{terminal}",
			desc = "💻 终端最新输出",
			note = "注入终端窗口中最近一次命令的输出内容",
			ex = "根据 `#{terminal}` 的报错告诉我怎么改",
		},
	}),
	build_group("【Git 与审查】", {
		{
			cmd = "#{diff}",
			desc = "🔀 暂存与未暂存的 Git 变更",
			note = "注入 git diff 的结果，包含已暂存和未暂存的所有改动",
			ex = "给 `#{diff}` 写一段 Commit Message",
		},
		{
			cmd = "#{code_review}",
			desc = "🧐 待处理的代码审查意见",
			note = "注入代码审查中标记的评论内容，让 AI 逐条处理",
			ex = "根据 `#{code_review}` 修改代码",
		},
		{
			cmd = "#{messages}",
			desc = "💬 Neovim 历史消息记录",
			note = "注入 Neovim 命令行中的历史消息，包括报错、提示等",
			ex = "总结一下 `#{messages}` 里的上下文",
		},
	}),
}

-- 数据部分：斜杠命令
local data_commands = {
	build_group("【添加上下文】", {
		{
			cmd = "/buffer",
			desc = "📥 选择添加缓冲区",
			note = "弹出文件选择器，挑选要注入对话的缓冲区",
			ex = "`/buffer`",
		},
		{
			cmd = "/file",
			desc = "📂 选择添加本地文件",
			note = "从文件系统中选择任意文件注入对话",
			ex = "`/file`",
		},
		{
			cmd = "/fetch",
			desc = "🌐 抓取并添加 URL",
			note = "抓取网页内容转为文本后注入对话",
			ex = "`/fetch`",
		},
		{
			cmd = "/file-from-url",
			desc = "⬇️ 下载文件并添加",
			note = "下载远程文件到本地后再注入对话",
			ex = "`/file-from-url`",
		},
		{
			cmd = "/help",
			desc = "❓ 搜索 Vim 帮助",
			note = "搜索 Neovim 帮助文档并将结果注入对话",
			ex = "`/help`",
		},
		{
			cmd = "/symbols",
			desc = "🔣 生成符号大纲",
			note = "生成当前文件的函数/类/变量符号树",
			ex = "`/symbols`",
		},
		{
			cmd = "/tools",
			desc = "🛠️ 手动添加指定工具",
			note = "手动选择要授予 AI 的工具，而非用 @{agent} 全部授予",
			ex = "`/tools`",
		},
		{
			cmd = "/rules",
			desc = "📜 添加项目规则组",
			note = "选择并加载规则文件，让 AI 遵循项目约定",
			ex = "`/rules`",
		},
	}),
	build_group("【会话与高级管理】", {
		{
			cmd = "/compact",
			desc = "🗜️ 压缩历史为摘要",
			note = "把长对话压缩成简短摘要，节省 token 消耗",
			ex = "`/compact`",
		},
		{
			cmd = "/fork",
			desc = "🍴 复制当前会话",
			note = "基于当前对话创建一个分支，尝试不同方向",
			ex = "`/fork`",
		},
		{
			cmd = "/save",
			desc = "💾 保存当前聊天会话",
			note = "将对话保存到文件，下次可以恢复",
			ex = "`/save`",
		},
		{
			cmd = "/resume",
			desc = "🔄 恢复之前的会话",
			note = "加载之前保存的对话，继续未完成的工作",
			ex = "`/resume`",
		},
		{
			cmd = "/rename",
			desc = "🏷️ 重命名当前聊天",
			note = "给当前对话起个名字，方便后续查找",
			ex = "`/rename`",
		},
		{
			cmd = "/share",
			desc = "🔗 分享为 GitHub Gist",
			note = "将对话内容上传为 GitHub Gist 并返回链接",
			ex = "`/share`",
		},
		{
			cmd = "/now",
			desc = "⏱️ 插入当前时间戳",
			note = "在消息中插入当前日期时间",
			ex = "`/now`",
		},
		{
			cmd = "/mode",
			desc = "🔀 切换代理工作模式",
			note = "切换 AI 的工具审批模式，控制自主程度",
			ex = "`/mode`",
		},
		{
			cmd = "/mcp",
			desc = "🔌 管理 MCP 工具服务器",
			note = "查看、启用或配置通过 mcphub.nvim 接入的外部 MCP 工具服务器",
			ex = "`/mcp`",
		},
	}),
	build_group("【提示词快捷调用】", {
		{
			cmd = "/commit",
			desc = "📝 自动生成 Commit",
			note = "根据当前 Git 暂存区的变更自动生成 commit message",
			ex = "`/commit`",
		},
		{
			cmd = "/explain",
			desc = "📖 自动解释当前代码",
			note = "让 AI 解释选中代码的功能、逻辑和关键细节",
			ex = "`/explain`",
		},
	}),
}

-- 通用渲染函数
local function show_cheatsheet(title, groups)
	local lines = {}
	local line_to_item = {}

	for _, group in ipairs(groups) do
		table.insert(lines, "  " .. group.title)
		for _, item in ipairs(group.items) do
			local left = pad_str("    " .. item.cmd, 24)
			table.insert(lines, left .. " │ " .. item.desc)
			line_to_item[#lines] = item
		end
		table.insert(lines, "")
	end

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].filetype = "help"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].modifiable = false

	local ui = vim.api.nvim_list_uis()[1] or { width = 80, height = 24 }
	local width = 75
	local main_height = math.min(#lines + 2, math.floor(ui.height * 0.5))
	local preview_height = 6

	local total_height = main_height + preview_height + 2
	local row = math.floor((ui.height - total_height) / 2)
	local col = math.floor((ui.width - width) / 2)

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = main_height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		title = " " .. title .. " ",
		title_pos = "center",
	})

	vim.wo[win].wrap = true
	vim.wo[win].cursorline = true

	local preview_buf = vim.api.nvim_create_buf(false, true)
	vim.bo[preview_buf].bufhidden = "wipe"
	vim.bo[preview_buf].modifiable = true

	local preview_win = vim.api.nvim_open_win(preview_buf, false, {
		relative = "editor",
		width = width,
		height = preview_height,
		row = row + main_height + 1,
		col = col,
		style = "minimal",
		border = "rounded",
		title = " 💡 说明 ",
		title_pos = "center",
	})
	vim.wo[preview_win].wrap = true

	local last_line = -1
	local hl_ns = vim.api.nvim_create_namespace("cc_preview_hl")

	local function update_preview()
		local current_line = vim.api.nvim_win_get_cursor(win)[1]
		if current_line == last_line then
			return
		end
		last_line = current_line

		local item = line_to_item[current_line]
		local text = {}

		vim.bo[preview_buf].modifiable = true
		vim.api.nvim_buf_clear_namespace(preview_buf, hl_ns, 0, -1)

		if item then
			-- 第一行：命令名
			table.insert(text, "  " .. item.cmd)
			-- 第二行：简单解释这个工具是干嘛的
			table.insert(text, "  " .. (item.note or item.desc))
			table.insert(text, "")
			-- 第四行：示例
			local raw_ex = item.ex or "无"
			local parsed_ex, highlights = parse_highlights("  [示例] " .. raw_ex)
			table.insert(text, parsed_ex)

			vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, text)

			for _, hl in ipairs(highlights) do
				vim.api.nvim_buf_add_highlight(preview_buf, hl_ns, hl.group, 3, hl.start_col, hl.end_col)
			end
		else
			table.insert(text, "  (上下移动光标查看说明)")
			vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, text)
		end

		vim.bo[preview_buf].modifiable = false
	end

	update_preview()

	vim.api.nvim_create_autocmd("CursorMoved", {
		buffer = buf,
		callback = update_preview,
	})

	vim.api.nvim_create_autocmd("WinClosed", {
		pattern = tostring(win),
		once = true,
		callback = function()
			if vim.api.nvim_win_is_valid(preview_win) then
				vim.api.nvim_win_close(preview_win, true)
			end
		end,
	})

	local close_cmd = "<cmd>close<CR>"
	-- 按键保持不变，只换成未废弃的 API
	local opts = { buffer = buf, silent = true, nowait = true }

	vim.keymap.set("n", "q", close_cmd, opts)
	vim.keymap.set("n", "<Esc>", close_cmd, opts)
	vim.keymap.set("n", "j", "j", opts)
	vim.keymap.set("n", "k", "k", opts)
	vim.keymap.set("n", "<C-d>", "<C-d>", opts)
	vim.keymap.set("n", "<C-u>", "<C-u>", opts)
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "codecompanion",
	callback = function(args)
		local opts = { buffer = args.buf, silent = true }

		vim.keymap.set("n", "<leader>@", function()
			show_cheatsheet("🤖 @ 工具 (Tools)", data_tools)
		end, vim.tbl_extend("force", opts, { desc = "CodeCompanion: @ 工具速查" }))

		vim.keymap.set("n", "<leader>#", function()
			show_cheatsheet("📋 # 上下文变量 (Variables)", data_context)
		end, vim.tbl_extend("force", opts, { desc = "CodeCompanion: # 变量速查" }))

		vim.keymap.set("n", "<leader>/", function()
			show_cheatsheet("⚡ / 斜杠命令 (Slash Commands)", data_commands)
		end, vim.tbl_extend("force", opts, { desc = "CodeCompanion: / 命令速查" }))
	end,
})
