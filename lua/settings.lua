local o = vim.opt

-- netrw 交由 nvim-tree 接管（必须在插件加载前设置）
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- 取消自动注释
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead", "FileType" }, {
	pattern = "*",
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
	end,
})

-- 开启持久化撤销历史
o.undofile = true

-- 集中存放撤销文件，避免 .un~ 文件散落在项目目录里（目录必须先存在，否则静默失效）
local undodir = vim.fn.expand("~/.data/nvim/undo")
vim.fn.mkdir(undodir, "p")
o.undodir = undodir

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

-- CursorHold 类事件（LSP 引用高亮）响应更快
o.updatetime = 300

-- 前缀键等待时间（<leader>f 与 <leader>ff 等存在前缀关系）
o.timeoutlen = 300
