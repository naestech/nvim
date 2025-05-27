return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		-- import mason
		local mason = require("mason")
		-- import mason-lspconfig
		local mason_lspconfig = require("mason-lspconfig")
		local mason_tool_installer = require("mason-tool-installer")

		-- enable mason and configure icons
		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		mason_lspconfig.setup({
			-- list of servers for mason to install
			ensure_installed = {
				-- primary languages
				"pyright", -- python
				"ts_ls", -- typescript / javascript
				"html", -- html
				"cssls", -- css
				"tailwindcss", -- tailwind css

				-- secondary languages
				"omnisharp", -- .net / c#
				"clangd", -- c / c++
				"phpactor", -- php
				"bashls", -- bash
				"lua_ls", -- lua

				-- languages to learn
				"gopls", -- go
				"rust_analyzer", -- rust
			},
			-- auto-setup installed servers
			automatic_installation = true,
		})

		mason_tool_installer.setup({
			ensure_installed = {
				-- formatters / linters
				"prettier", -- prettier formatter
				"stylua", -- lua formatter
				"isort", -- python formatter
				"black", -- python formatter
				"pylint", -- python linter
				"eslint_d", -- js linter

				-- additional tools
				"flake8", -- python linter (alternative to pylint)
				"gofumpt", -- go formatter
				"rustfmt", -- rust formatter
				"clang-format", -- c/c++ formatter
				"php-cs-fixer", -- php formatter
				"phpcs", -- php linter
				"shfmt", -- shell script formatter
				"shellcheck", -- shell script linter
			},
		})
	end,
}
