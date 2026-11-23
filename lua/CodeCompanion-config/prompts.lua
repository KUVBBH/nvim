local M = {}

-- 工厂：系统提示 + 用户提示构造器
-- 注意：context 由 codecompanion 提供（含 code / bufnr / filetype / start_line / end_line）
local function code_prompt(index, short, desc, sys, build_user)
	return {
		strategy = "chat",
		description = desc,
		opts = {
			index = index,
			is_default = true,
			is_slash_cmd = false,
			modes = { "v" },
			short_name = short,
			auto_submit = true,
			user_prompt = false,
			stop_context_insertion = true,
		},
		prompts = {
			{ role = "system", content = sys, opts = { visible = false } },
			{
				role = "user",
				content = function(context)
					context = context or {}
					return build_user(context, context.code or "")
				end,
				opts = { contains_code = true },
			},
		},
	}
end

M.library = {
	["中文解释代码"] = code_prompt(
		1,
		"explain_cn",
		"用中文解释选中的代码",
		"当被要求解释代码时，请遵循以下步骤:",
		function(ctx, input)
			return ("请解释 buffer %d 中的这段代码:\n```%s\n%s\n```"):format(ctx.bufnr, ctx.filetype, input)
		end
	),
	["中文修复代码"] = code_prompt(
		2,
		"fix_cn",
		"用中文分析并修复选中的代码问题",
		"你是一个代码审查专家。分析代码中的问题，用中文解释问题原因，然后提供修复后的完整代码。",
		function(ctx, input)
			return ("请分析并修复以下代码中的问题:\n```%s\n%s\n```"):format(ctx.filetype, input)
		end
	),
}

return M
