return {
	"neovim/nvim-lspconfig",

	event = { "BufReadPre", "BufNewFile" },

	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
		"williamboman/mason-lspconfig.nvim",
	},

	config = function()
		local lspconfig = require("lspconfig")
		local mason_lspconfig = require("mason-lspconfig")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local keymap = vim.keymap

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				local opts = { buffer = ev.buf, silent = true }
				opts.desc = "Show LSP references"
				keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)
				opts.desc = "Go to declaration"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				opts.desc = "Show LSP definitions"
				keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
				opts.desc = "Show LSP implementations"
				keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
				opts.desc = "Show LSP type definitions"
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)
				opts.desc = "See available code actions"
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
				opts.desc = "Smart rename"
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)
				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
				opts.desc = "Go to next diagnostic"
				keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
				opts.desc = "Show documentation for what is under cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts)
				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
			end,
		})

		local capabilities = cmp_nvim_lsp.default_capabilities()
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		mason_lspconfig.setup({
			ensure_installed = {
				-- frequent languages
				"pyright", -- python
				"ts_ls", -- typescript / javascript
				"html", -- html
				"cssls", -- css

				-- secondary languages
				"omnisharp", -- .net / c#
				"clangd", -- c / c++
				"phpactor", -- php
				"bashls", -- bash
				"lua_ls", -- lua
				"tailwindcss", -- tailwind css

				-- languages to learn
				"gopls", -- go
				"rust_analyzer", -- rust
			},
			handlers = {
				-- default handler for servers without specific config
				function(server_name)
					lspconfig[server_name].setup({
						capabilities = capabilities,
					})
				end,

				-- python
				["pyright"] = function()
					lspconfig.pyright.setup({
						capabilities = capabilities,
						settings = {
							python = {
								analysis = {
									typeCheckingMode = "basic",
									autoSearchPaths = true,
									useLibraryCodeForTypes = true,
								},
							},
						},
					})
				end,

				-- typescript / javascript
				["ts_ls"] = function()
					lspconfig.ts_ls.setup({
						capabilities = capabilities,
					})
				end,

				-- html
				["html"] = function()
					lspconfig.html.setup({
						capabilities = capabilities,
						filetypes = { "html", "templ" },
					})
				end,

				-- tailwind css
				["tailwindcss"] = function()
					lspconfig.tailwindcss.setup({
						capabilities = capabilities,
						settings = {
							tailwindCSS = {
								experimental = {
									classRegex = {
										"tw`([^`]*)",
										'tw="([^"]*)',
										'tw={"([^"]*)',
										"tw\\.\\w+`([^`]*)",
										"tw\\(.*?\\)`([^`]*)",
									},
								},
							},
						},
					})
				end,

				-- .net / c#
				["omnisharp"] = function()
					lspconfig.omnisharp.setup({
						capabilities = capabilities,
						cmd = { "omnisharp" },
						settings = {
							FormattingOptions = {
								EnableEditorConfigSupport = true,
								OrganizeImports = true,
							},
							MsBuild = {
								LoadProjectsOnDemand = false,
							},
							RoslynExtensionsOptions = {
								EnableAnalyzersSupport = true,
								EnableImportCompletion = true,
							},
						},
					})
				end,

				-- c / c++
				["clangd"] = function()
					lspconfig.clangd.setup({
						capabilities = capabilities,
						cmd = {
							"clangd",
							"--background-index",
							"--clang-tidy",
							"--header-insertion=iwyu",
							"--completion-style=detailed",
							"--function-arg-placeholders",
							"--fallback-style=llvm",
						},
					})
				end,

				-- go
				["gopls"] = function()
					lspconfig.gopls.setup({
						capabilities = capabilities,
						settings = {
							gopls = {
								analyses = {
									unusedparams = true,
								},
								staticcheck = true,
								gofumpt = true,
							},
						},
					})
				end,

				-- rust
				["rust_analyzer"] = function()
					lspconfig.rust_analyzer.setup({
						capabilities = capabilities,
						settings = {
							["rust-analyzer"] = {
								cargo = {
									allFeatures = true,
								},
								checkOnSave = {
									command = "clippy",
								},
							},
						},
					})
				end,

				-- lua
				["lua_ls"] = function()
					lspconfig.lua_ls.setup({
						capabilities = capabilities,
						settings = {
							Lua = {
								diagnostics = {
									globals = { "vim" },
								},
								completion = {
									callSnippet = "Replace",
								},
							},
						},
					})
				end,
			},
		})
	end,
}
