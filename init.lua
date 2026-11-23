vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- 启用 Lua 模块缓存，加快启动
vim.loader.enable()

-- 基础选项与键位必须在插件之前就绪
require("settings")
require("keymaps")

require("config.lazy")

-- 与插件无强依赖（或依赖启动即加载的插件）的纯原生模块
require("key-help")
require("lazyvim-zh")
