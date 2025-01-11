return {
	url = "https://codeberg.org/jthvai/lavender.nvim",
	branch = "stable", -- versioned tags + docs updates from main
	lazy = false,
	priority = 1000,
	config = function()
		-- Add configuration before setting colorscheme
		vim.g.lavender = {
			transparent = {
				background = false,
				float = false,
				popup = false,
				sidebar = false,
			},
			contrast = true,
			italic = {
				comments = true,
				functions = true,
				keywords = false,
				variables = false,
			},
			signs = false,
		}

		-- Set the colorscheme
		vim.cmd("colorscheme lavender")
	end,
}
