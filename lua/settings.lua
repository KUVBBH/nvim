local o = vim.opt

-- 取消自动注释
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead", "FileType" }, {
	pattern = "*",
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
	end,
})

-- 行号
o.number = true

-- 相对行号
o.relativenumber = true

-- 缩进
o.tabstop = 2
o.shiftwidth = 2
o.softtabstop = 2
o.autoindent = true
o.expandtab = true

-- 防止包裹
o.wrap = false

-- 突出显示光标行
o.cursorline = true

-- 终端真颜色
o.termguicolors = true

-- 左侧列
o.signcolumn = "yes"

o.hlsearch = true

-- 开启折行
o.wrap = true

-- 在单词边界折行，而不是在单词中间截断
o.linebreak = true

-- 折行后的部分保持缩进（看代码更舒服)
o.breakindent = true
