vim.cmd[[colorscheme tokyonight-moon]]
require("lualine").setup({
  options = {
  theme = "tokyonight",
  icons_enabled = false,
  section_separators = { left = "", right = "" },
  component_separators = { left = "|", right = "|" },
  },
})
