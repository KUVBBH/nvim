vim.g.mapleader=" "
vim.g.maplocalleader = ""

local k = vim.keymap.set
local opts = { noremap = true, silent = true }

-- 块移动
k("v", "J", ":m '>+1<CR>gv=gv",opts)
k("v", "K", ":m '<-2<CR>gv=gv",opts)

-- 保存并退出
k("n", "<leader>q", ":wq<CR>",opts)

-- 退出
k("n", "<leader>!", ":q!<CR>",opts)

-- 保存
k("n", "<leader>w", ":w<CR>",opts)

-- 取消高亮
k("n", "<leader>nh", ":nohl<CR>",opts)

-- NvimTreeOpen
k("n", "<leader>n", ":NvimTreeOpen<CR>",opts)


