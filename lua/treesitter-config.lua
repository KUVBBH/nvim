-- 1. 定义要用到的语言（安装白名单）
-- 注意：shell 脚本的 filetype 是 sh，不是 bash
local parser_languages = {
	"lua",
	"python",
	"html",
	"css",
	"markdown",
	"markdown_inline",
	-- shell 的 parser 名是 bash（filetype 才是 sh）
	"bash",
}

-- 显式登记 filetype -> parser 映射，避免依赖插件内部默认映射
pcall(vim.treesitter.language.register, "bash", "sh")

-- 2. 只安装缺失的解析器（不要每次启动都跑一遍全量安装）
local ok, treesitter = pcall(require, "nvim-treesitter")
if ok then
	local has_all, installed = pcall(treesitter.get_installed)
	if has_all then
		local missing = vim.tbl_filter(function(lang)
			return not vim.tbl_contains(installed, lang)
		end, parser_languages)
		if #missing > 0 then
			treesitter.install(missing)
		end
	else
		treesitter.install(parser_languages)
	end
end

-- 3. 需要自动开启高亮的 filetype（filetype -> parser 名）
-- markdown_inline 由 markdown 注入，不单独 start
local highlight_languages = {
	["lua"] = "lua",
	["python"] = "python",
	["html"] = "html",
	["css"] = "css",
	["markdown"] = "markdown",
	["sh"] = "bash",
}

vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		local ft = vim.bo[args.buf].filetype
		local lang = highlight_languages[ft]
		if lang then
			pcall(vim.treesitter.start, args.buf, lang)
		end
	end,
})
