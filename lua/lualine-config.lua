vim.cmd([[colorscheme tokyonight-moon]])
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("lualine").setup({
	options = {
		theme = "tokyonight",
		-- icons_enabled = false,
		-- section_separators = { left = "", right = "" },
		-- component_separators = { left = "|", right = "|" },
	},
})
