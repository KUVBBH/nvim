-- lua/atone-config.lua
local atone = require("atone")

atone.setup({
	-- 这里写你的自定义配置
	layout = { direction = "left", width = 0.9 },
	auto_attach = { enabled = false },
})

-- 如果需要快捷键，可以在这里直接定义
