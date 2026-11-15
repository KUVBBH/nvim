vim.g.mapleader = " "
-- vim.g.maplocalleader = " "

local k = vim.keymap.set
local opts = { noremap = true, silent = true }

-- 块移动
k("v", "J", ":m '>+1<CR>gv=gv", opts)
k("v", "K", ":m '<-2<CR>gv=gv", opts)

-- 保存并退出
k("n", "<leader>q", ":wq<CR>", { desc = "保存并退出" }, opts)

-- 退出
k("n", "<leader>!", ":q!<CR>", { desc = "退出" }, opts)

-- buffer切换
k("n", "<leader><right>", ":bnext<CR>", { desc = "下一个buffer" }, opts)
k("n", "<leader><left>", ":bprevious<CR>", { desc = "上一个buffer" }, opts)
k("n", "<leader>b", ":bd<CR>", { desc = "关闭buffer" }, opts)

-- 保存
k("n", "<leader><leader>", ":w<CR>", { desc = "保存" }, opts)

-- 取消高亮
k("n", "<leader>N", ":nohl<CR>", { desc = "取消高亮" }, opts)

-- NvimTreeOpen
k("n", "<leader>n", ":NvimTreeOpen<CR>", opts)

-- undo tree
vim.keymap.set("n", "<leader>u", "<cmd>Atone toggle<CR>", { desc = "Undo Tree" })

-- autopairs
vim.keymap.set("n", "<leader>(", function()
	local ok, autopairs = pcall(require, "nvim-autopairs")
	if not ok then
		print("autopairs not available")
		return
	end

	if autopairs.state.disabled then
		autopairs.enable()
		print("autopairs on")
	else
		autopairs.disable()
		print("autopairs off")
	end
end, { desc = "Toggle Autopairs" })

-- formatter
k({ "n", "v" }, "<leader>f", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer" })

-- python
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function(ev)
		vim.keymap.set("n", "<leader>r", function()
			vim.cmd("write")
			local file = vim.fn.shellescape(vim.fn.expand("%"))
			vim.cmd("!python " .. file)
		end, { buffer = ev.buf, desc = "运行" })
	end,
})
