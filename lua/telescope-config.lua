require("telescope").setup({
	defaults = {
		-- 此处为 telescope 的默认配置：
		-- config_key = value,
		mappings = {
			i = {
				-- 将 actions.which_key 映射到 <C-h>（默认：<C-/>）
				-- actions.which_key 会显示该选择器的映射，
				-- 例如 git_branches 选择器的 git_{create, delete, ...}_branch
				["<C-h>"] = "which_key",
			},
		},
	},
	pickers = {
		-- 此处为内置选择器的默认配置：
		-- picker_name = {
		--   picker_config_key = value,
		--   ...
		-- }
		-- 现在每次调用该内置选择器时都会应用 picker_config_key
	},
	extensions = {
		-- 此处为扩展配置：
		-- extension_name = {
		--   extension_config_key = value,
		-- }
		-- 请查看你要配置的扩展的 readme
	},
})
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "查找文件" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "实时搜索" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "查看缓冲区" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "帮助标签" })
