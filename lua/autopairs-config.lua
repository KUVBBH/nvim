local npairs = require("nvim-autopairs")
local Rule = require("nvim-autopairs.rule")

-- 只调用一次 setup：opts 会整体覆盖配置，别在别处再 setup 一遍
npairs.setup({
	check_ts = true, -- 借助 Treesitter，避免在字符串/注释里误触发
})

-- () [] {} "" '' 都是 autopairs 内置规则，重复添加只会带来意外
-- 只补充内置没有的尖括号，且限定在标记类语言里，避免 Lua/Python 的 a < b 被自动补右括号
npairs.add_rules({
	Rule("<", ">", { "html", "xml", "vue", "javascriptreact", "typescriptreact" }),
})
