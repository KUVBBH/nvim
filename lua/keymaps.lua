vim.g.mapleader = " "
vim.g.maplocalleader = " "

local k = vim.keymap.set
local opts = { noremap = true, silent = true }

-- 块移动
k("v", "J", ":m '>+1<CR>gv=gv", opts)
k("v", "K", ":m '<-2<CR>gv=gv", opts)

-- 保存并退出
k("n", "<leader>q", ":wq<CR>", { desc = "保存并退出" }, opts)

-- 退出
k("n", "<leader>!", ":q!<CR>", { desc = "退出" }, opts)

-- 保存
k("n", "<leader><leader>", ":w<CR>", { desc = "保存" }, opts)

-- 取消高亮
k("n", "<leader>nh", ":nohl<CR>", { desc = "取消高亮" }, opts)

-- NvimTreeOpen
k("n", "<leader>n", ":NvimTreeOpen<CR>", opts)

-- formatter
k({ "n", "v" }, "<leader>f", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer" })

-- python
vim.keymap.set("n", "<LocalLeader>r", function()
	vim.cmd("write")
	local file = vim.fn.shellescape(vim.fn.expand("%"))
	vim.cmd("!python3 " .. file)
end, {
	buffer = true,
	desc = "运行",
})
