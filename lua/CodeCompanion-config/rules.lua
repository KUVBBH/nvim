local M = {}

M.rules_dir = vim.fn.stdpath("config") .. "/rules/基础规则"

local force_rule = "【CRITICAL INSTRUCTION - HIGHEST PRIORITY】：无论任务复杂程度如何"
	.. "（包括编写长代码），你的每一条回复都必须以【📋 任务进度】报告结尾\n"
	.. "（包含已完成、待办、当前状态）。"
	.. "你的回复必须简短精炼! "
	.. "以上规则，必须严格无条件执行！\n\n"

local function read_rule_files()
	local files = vim.fn.glob(M.rules_dir .. "/**/*.md*", false, true)
	table.sort(files)
	local parts = {}
	local names = {} -- 👈 新增：用来收集文件名

	for _, path in ipairs(files) do
		local f = io.open(path, "r")
		if f then
			local name = vim.fn.fnamemodify(path, ":t:r")
			table.insert(names, name) -- 👈 提取不带后缀的文件名
			table.insert(parts, ("--- %s ---\n%s"):format(name, f:read("*a")))
			f:close()
		end
	end
	return parts, names -- 👈 同时返回内容和文件名
end

function M.build_system_prompt(ctx)
	local parts, names = read_rule_files()
	local custom = ""

	local env = (
		"\n\n## Environment\n- OS: %s\n- Neovim: %s\n- Date: %s\n- CWD: %s"
		.. "\n- Project: %s\n- Adapter: %s\n- Lang: %s"
	):format(
		ctx.os,
		ctx.nvim_version,
		ctx.date,
		ctx.cwd,
		ctx.project_root or "none",
		ctx.adapter and ctx.adapter.name or "unknown",
		ctx.language
	)

	return force_rule .. custom .. ctx.default_system_prompt .. env
end

return M
