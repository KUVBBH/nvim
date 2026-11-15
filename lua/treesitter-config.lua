-- 1. 定义你要用到的语言（白名单）
local supported_languages = {
	["lua"] = true,
	["python"] = true,
	["html"] = true,
	["css"] = true,
	["markdown"] = true, -- 需要的话可以加上
	["markdown_inline"] = true,
	["bash"] = true,
}

-- 提取所有的 key 变成数组，用于安装
local langs_to_install = vim.tbl_keys(supported_languages)

-- 2. 安装这些语言的解析器
require("nvim-treesitter").install(langs_to_install)

-- 3. 核心：白名单自动开启逻辑
vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		local ft = vim.bo[args.buf].filetype

		-- 只要 filetype 在白名单里，才尝试开启高亮
		if supported_languages[ft] then
			pcall(vim.treesitter.start, args.buf, ft)
		end
	end,
})
