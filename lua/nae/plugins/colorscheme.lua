return {
	"ptdewey/darkearth-nvim",
	dependencies = {
		"rktjmp/lush.nvim",
	},
	priority = 1000,
	config = function()
		vim.o.termguicolors = true
		vim.cmd("colorscheme darkearth")
	end,
}
