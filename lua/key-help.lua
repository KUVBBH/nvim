-- 获取字符实际显示宽度（中文占2格，英文占1格）
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

-- 定义数据表
local help_data = {
	{
		name = "1. 基础操作",
		items = {
			{ "i, I", "在前/行首插入" },
			{ "a, A", "在后/行尾插入" },
			{ "<Esc>", "返回普通模式" },
			{ "hjkl", "左下上右移动" },
			{ "x", "删除光标下的字符" },
			{ "dd", "剪切 (删除) 当前行" },
			{ "u", "撤销" },
			{ "U", "撤销当前行的所有修改" },
			{ "CTRL-R", "重做 (Redo)" },
			{ "o, O", "在下方/上方新建空行进入插入模式" },
			{ ":w, ZZ", "保存, 保存并退出" },
			{ ":q!", "强制退出 (放弃修改)" },
			{ ":q", "退出" },
			{ ":e!", "重新加载当前文件" },
		},
	},
	{
		name = "2. 移动与查找",
		items = {
			{ "w, b", "移动到下/上一个词的词首" },
			{ "e, ge", "移动到下/上一个词的词尾" },
			{ "W, B, E, gE", "按空白符计算的字串移动" },
			{ "$", "移动到行尾" },
			{ "0", "移动到行首 (第0列)" },
			{ "^", "移动到行首非空字符" },
			{ "fx, Fx", "向右/向左查找字符 x 并跳转" },
			{ "tx, Tx", "跳转到字符 x 的前一个位置" },
			{ "%", "在配对括号间跳转" },
			{ "gg, G", "跳转到文件开头/结尾" },
			{ "15gg, 15G", "跳转到第 15 行" },
			{ "50%", "跳转到文件 50% 的位置" },
			{ "H, M, L", "跳转到当前屏幕的首/中/尾" },
			{ "CTRL-U, CTRL-D", "向上/下半屏滚动" },
			{ "CTRL-F, CTRL-B", "向上/下翻一页" },
			{ "zt, zz, zb", "将当前行置于屏幕顶/中/底" },
			{ "/x, ?x", "向下/向上搜索 x" },
			{ "n, N", "跳转到下/上一个搜索结果" },
			{ "``", "在两次跳转位置之间来回切换" },
			{ "CTRL-O, CTRL-I", "跳转到较老/较新的位置" },
			{ "ma", "标记当前位置为 a" },
			{ "`a", "跳转到标记 a" },
		},
	},
	{
		name = "3. 编辑与可视模式",
		items = {
			{ "D", "删除到行尾 (同 d$)" },
			{ "dw", "删除到下一个词首" },
			{ "diw", "删除光标处的词 (不含空格)" },
			{ "daw", "删除光标处的词 (含空格)" },
			{ "dG, dgg", "删除到文件末尾/开头" },
			{ "~", "翻转光标下字符的大小写" },
			{ "cw", "修改当前词并进入插入模式" },
			{ "cc", "修改当前行并进入插入模式" },
			{ "C", "删除到行尾并进入插入模式" },
			{ "s", "删除当前字符并进入插入模式" },
			{ "S", "修改当前行并进入插入模式" },
			{ "r, R", "替换单个字符 / 进入替换模式" },
			{ ".", "重复上一次修改操作" },
			{ "v", "进入可视模式" },
			{ "V", "进入可视行模式" },
			{ "CTRL-V", "进入可视块模式" },
			{ "p, P", "在光标后/前粘贴" },
			{ "xp", "交换光标处的两个字符" },
			{ "yy, Y", "复制当前行" },
			{ "yw", "复制当前词" },
			{ "y$", "复制到行尾" },
			{ '"1yy', "复制当前行到寄存器 1" },
		},
	},
	{
		name = "4. 分屏与标签页",
		items = {
			{ ":split, :vsplit", "上下/左右分屏" },
			{ "CTRL-W w", "在窗口间循环切换" },
			{ "CTRL-W h/j/k/l", "跳转到左/下/上/右侧窗口" },
			{ "CTRL-W H/J/K/L", "移动窗口到最左/下/上/右侧" },
			{ ":qall, :wall", "全部退出/保存" },
			{ ":tab split", "在新标签页打开当前文件" },
			{ ":tabclose", "关闭当前标签页" },
			{ "gt, gT", "切换到下/上一个标签页" },
			{ ":tabs", "列出所有标签页" },
		},
	},
	{
		name = "5. 宏替换与折叠",
		items = {
			{ "qa", "录制宏到寄存器 a" },
			{ "q", "停止录制" },
			{ "@a", "执行 1 次寄存器 a 中的宏" },
			{ "@@", "重复上一次执行的宏" },
			{ ":%s/old/new/g", "全文所有 old 替换为 new" },
			{ ":s/old/new/g", "当前行所有 old 替换为 new" },
			{ "zf4j", "折叠当前行及下方 4 行" },
			{ "zo, zc", "打开/关闭当前折叠" },
			{ "zR, zM", "展开/收起所有折叠" },
		},
	},
	{
		name = "6. 文本对象与寄存器",
		items = {
			{ "aw, aW", "一个单词/大字串 (含空格)" },
			{ "iw, iW", "内含单词/大字串 (不含空格)" },
			{ "ap, ip", "一个段落/内含段落" },
			{ "a(, i(, ab", "一个 () 块 / 内含 () 块" },
			{ "a{, i{, aB", "一个 {} 块 / 内含 {} 块" },
			{ 'a", i"', "一个引号块 / 内含引号内容" },
			{ "dib, dab", "删除括号内的内容/删除整个块" },
			{ ":reg", "查看所有寄存器内容" },
		},
	},
}

-- 渲染并打开浮窗
local function show_cheatsheet()
	local lines = {}
	local max_key_width = 18 -- 左侧按键部分的最大宽度（缩小一点，给右侧留空间）

	for _, category in ipairs(help_data) do
		-- 添加分类标题
		table.insert(lines, "  " .. category.name)
		table.insert(lines, "  " .. string.rep("─", 55))

		for _, item in ipairs(category.items) do
			-- 使用 pad_str 保证左边对齐，中间用 │ 分割
			local left = pad_str("  " .. item[1], max_key_width)
			local right = item[2]
			table.insert(lines, left .. " │ " .. right)
		end
		table.insert(lines, "") -- 分类之间空一行
	end

	-- 创建 buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	vim.api.nvim_buf_set_option(buf, "filetype", "help")

	-- 允许光标移动和滚动
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

	-- 【关键修复】计算窗口大小：宽度定死，高度拉到屏幕的 90%
	local ui = vim.api.nvim_list_uis()[1]
	local width = 65
	-- 高度取屏幕高度的 90%
	local height = math.floor(ui.height * 0.9)

	local row = math.floor((ui.height - height) / 2)
	local col = math.floor((ui.width - width) / 2)

	-- 打开浮窗
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		title = " 🚀 VIM 速查表 ",
		title_pos = "center",
	})

	-- 开启 wrap 防止横向被截断
	vim.api.nvim_win_set_option(win, "wrap", true)
	-- 开启光标行高亮，方便看看到底滚到了哪
	vim.api.nvim_win_set_option(win, "cursorline", true)

	-- 设置浮窗内快捷键
	local close_cmd = "<cmd>close<CR>"
	local opts = { silent = true, noremap = true }

	-- 退出键
	vim.api.nvim_buf_set_keymap(buf, "n", "q", close_cmd, opts)
	vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", close_cmd, opts)

	-- 【新增】滚动键（直接利用原生 vim 命令）
	vim.api.nvim_buf_set_keymap(buf, "n", "j", "j", opts)
	vim.api.nvim_buf_set_keymap(buf, "n", "k", "k", opts)
	vim.api.nvim_buf_set_keymap(buf, "n", "<C-d>", "<C-d>", opts) -- 半屏向下
	vim.api.nvim_buf_set_keymap(buf, "n", "<C-u>", "<C-u>", opts) -- 半屏向上
	vim.api.nvim_buf_set_keymap(buf, "n", "<C-f>", "<C-f>", opts) -- 全屏向下
	vim.api.nvim_buf_set_keymap(buf, "n", "<C-b>", "<C-b>", opts) -- 全屏向上
	vim.api.nvim_buf_set_keymap(buf, "n", "G", "G", opts) -- 跳到底部
	vim.api.nvim_buf_set_keymap(buf, "n", "gg", "gg", opts) -- 跳到顶部
end

-- 绑定快捷键（比如按 leader + h 触发）
vim.keymap.set("n", "<leader>h", show_cheatsheet, { desc = "打开 VIM 速查表", silent = true })
