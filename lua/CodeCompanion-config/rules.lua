local M = {}

M.rules_dir = vim.fn.stdpath("config") .. "/rules/基础规则"

local force_rule = "【CRITICAL INSTRUCTION - HIGHEST PRIORITY】：无论任务复杂程度如何"
	.. "（包括编写长代码），你的每一条回复都必须以【📋 任务进度】报告结尾\n"
	.. "（包含已完成、待办、当前状态）。"
	.. "你的回复必须简短精炼! "
	.. "以上规则，必须严格无条件执行！\n\n"

-- 唯一一处规则扫描，init.lua / system_prompt 共用
function M.files()
	local files = vim.fn.glob(M.rules_dir .. "/*.md*", false, true)
	table.sort(files)
	return files
end

local function read_rule_files()
	local parts, names = {}, {}

	for _, path in ipairs(M.files()) do
		local f = io.open(path, "r")
		if f then
			local name = vim.fn.fnamemodify(path, ":t:r")
			table.insert(names, name)
			table.insert(parts, ("--- %s ---\n%s"):format(name, f:read("*a")))
			f:close()
		end
	end

	return parts, names
end

-- 供 /rules 选择器使用：每个规则文件一条记录
function M.build_table()
	local rules = {
		-- 规则内容已由 build_system_prompt 注入，这里不再 autoload，避免重复占用 token
		opts = { chat = { autoload = {} } },
	}

	for _, path in ipairs(M.files()) do
		local name = vim.fn.fnamemodify(path, ":t:r")
		rules[name] = {
			description = "自定义规则: " .. name,
			files = { path },
		}
	end

	return rules
end

function M.build_system_prompt(ctx)
	local parts = read_rule_files()
	local custom = #parts > 0 and (table.concat(parts, "\n\n") .. "\n\n") or ""

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
