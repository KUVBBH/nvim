local ru = {
	基础规则 = {
		description = "我的自定义规则",
		files = {
			-- 方式一：直接指向单个文件
			-- "~/.config/nvim/rules/my_style.md",
			-- 方式二：扫描整个目录（推荐）
			{ path = vim.fn.fnamemodify("~/ai_rules/my_rules/", ":p"), files = "*.md*" },
		},
	},
}
return ru
