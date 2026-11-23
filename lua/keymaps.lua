local k = vim.keymap.set

-- 统一包装：desc 用中文，silent 默认开启（noremap 是 nvim 默认行为，无需再写）
local function map(mode, lhs, rhs, desc)
	k(mode, lhs, rhs, { desc = desc, silent = true })
end

-- 块移动
map("v", "J", ":m '>+1<CR>gv=gv", "向下移动选中行")
map("v", "K", ":m '<-2<CR>gv=gv", "向上移动选中行")

-- 保存并退出
map("n", "<leader>q", ":wq<CR>", "保存并退出")

-- 退出
map("n", "<leader>!", ":q!<CR>", "退出")

-- buffer切换
map("n", "<leader><right>", ":bnext<CR>", "下一个buffer")
map("n", "<leader><left>", ":bprevious<CR>", "上一个buffer")
map("n", "<leader>b", ":bd<CR>", "关闭buffer")

-- 保存
map("n", "<leader><leader>", ":w<CR>", "保存")

-- 取消高亮
map("n", "<leader>N", ":nohl<CR>", "取消高亮")

-- NvimTreeOpen
map("n", "<leader>n", ":NvimTreeOpen<CR>", "打开文件树")

-- undo tree
map("n", "<leader>u", "<cmd>Atone toggle<CR>", "Undo Tree")

-- 跳转到定义（Go to Definition）
map("n", "gd", vim.lsp.buf.definition, "跳转到定义")

-- 跳转到声明（Go to Declaration，Python 中通常和定义一样）
map("n", "gD", vim.lsp.buf.declaration, "跳转到声明")

-- 查找函数被引用的地方（Find References）
map("n", "gr", vim.lsp.buf.references, "查找引用")

-- 重命名光标下的变量或函数（全项目生效）
map("n", "<leader>rn", vim.lsp.buf.rename, "LSP 重命名符号")

-- autopairs
map("n", "<leader>(", function()
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
end, "Toggle Autopairs")

-- formatter（注意：与 <leader>ff/fg/fb/fh 是前缀关系，按下后会等 timeoutlen）
map({ "n", "v" }, "<leader>f", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, "Format buffer")

-- python
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function(ev)
		-- 只对 python buffer 生效
		k("n", "<leader>R", function()
			vim.cmd("update")
			local file = vim.fn.shellescape(vim.fn.expand("%"))
			vim.cmd("!python3 " .. file)
		end, { buffer = ev.buf, desc = "运行", silent = true })
	end,
})
