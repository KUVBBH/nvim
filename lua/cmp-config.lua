local cmp = require("cmp")

cmp.setup({
	mapping = cmp.mapping.preset.insert({
		-- 只有显式选中了某一项，按回车才会确认，否则回车就是换行
		["<CR>"] = cmp.mapping.confirm({ select = false }),

		-- 当补全菜单出现时，Tab 向下选择；没有菜单时，Tab 正常缩进
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end, { "i", "s" }),

		-- Shift-Tab 向上选择
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
	sources = {
		{ name = "nvim_lsp" },
		{ name = "buffer" },
		{ name = "path" },
	},
})
