require("telescope").setup({
	defaults = {
		mappings = {
			i = {
				-- 将 actions.which_key 映射到 <C-h>（默认：<C-/>）
				["<C-h>"] = "which_key",
			},
		},
	},
	pickers = {},
	extensions = {},
})

-- 快捷键在 plugins/plug_list.lua 的 keys 中声明（保证按键不变且可懒加载）
