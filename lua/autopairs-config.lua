local npairs = require("nvim-autopairs")
local Rule = require("nvim-autopairs.rule")

npairs.setup()

npairs.add_rules({
	Rule("(", ")"),
	Rule("[", "]"),
	Rule("{", "}"),
	Rule('"', '"'),
	Rule("'", "'"),
	Rule("<", ">"), -- 你新增的尖括号配对
})
