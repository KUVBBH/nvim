require("nvim-treesitter")
	.install({
		"lua",
		"python",
		"html",
		"css",
	})
	:wait(300000) -- wait max. 5 minutes
