local compat = require("darkroam.compat")
local languages = require("darkroam.languages")

local function enabled_servers()
	local servers = {}
	if languages.syntax.lua then
		table.insert(servers, "lua_ls")
	end
	if languages.syntax.c then
		table.insert(servers, "clangd")
	end
	if languages.syntax.go then
		table.insert(servers, "gopls")
	end
	return servers
end

local lsp_enabled = function()
	return compat.supports("lsp")
end

local function use_standard_position_encodings(params)
	params.capabilities.offsetEncoding = nil
end

return {
	{
		"williamboman/mason.nvim",
		cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate", "MasonLog" },
		opts = {},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		cond = lsp_enabled,
		cmd = { "LspInstall", "LspUninstall" },
		dependencies = { "williamboman/mason.nvim" },
		opts = function()
			return {
				ensure_installed = enabled_servers(),
				automatic_enable = false,
			}
		end,
	},
	{
		"stevearc/conform.nvim",
		cmd = { "ConformInfo" },
		event = { "BufWritePre" },
		dependencies = { "williamboman/mason.nvim" },
		opts = function()
			local formatters_by_ft = {}
			if languages.syntax.lua then
				formatters_by_ft.lua = { "stylua" }
			end
			if languages.syntax.c then
				formatters_by_ft.c = { "clang-format" }
			end
			if languages.syntax.go then
				formatters_by_ft.go = { "gofmt" }
			end

			return {
				formatters_by_ft = formatters_by_ft,
				format_on_save = {
					timeout_ms = 500,
					lsp_format = "fallback",
				},
			}
		end,
	},
	{
		"neovim/nvim-lspconfig",
		cond = lsp_enabled,
		lazy = false,
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"williamboman/mason.nvim",
		},
		config = function()
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			vim.diagnostic.config({
				virtual_text = { prefix = "●" },
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = "E",
						[vim.diagnostic.severity.WARN] = "W",
						[vim.diagnostic.severity.INFO] = "I",
						[vim.diagnostic.severity.HINT] = "H",
					},
				},
				underline = true,
				update_in_insert = false,
				severity_sort = true,
				float = {
					border = "rounded",
					source = "always",
				},
			})

			local attach_group = vim.api.nvim_create_augroup("DarkroamLspAttach", { clear = true })
			local highlight_group = vim.api.nvim_create_augroup("DarkroamLspHighlight", { clear = true })
			vim.api.nvim_create_autocmd("LspAttach", {
				group = attach_group,
				callback = function(event)
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.name == "lua_ls" then
						client.server_capabilities.documentFormattingProvider = false
					end

					local function map(lhs, rhs, desc)
						vim.keymap.set("n", lhs, rhs, { buffer = event.buf, silent = true, desc = desc })
					end

					map("gD", vim.lsp.buf.declaration, "LSP declaration")
					map("gd", vim.lsp.buf.definition, "LSP definition")
					map("gi", vim.lsp.buf.implementation, "LSP implementation")
					map("gr", vim.lsp.buf.references, "LSP references")
					map("K", vim.lsp.buf.hover, "LSP hover")
					map("<leader>rn", vim.lsp.buf.rename, "LSP rename")
					map("<leader>ca", vim.lsp.buf.code_action, "LSP code action")
					map("<leader>lf", function()
						require("conform").format({ async = true, lsp_format = "fallback" })
					end, "Format buffer")
					map("[d", function()
						vim.diagnostic.jump({ count = -1, float = true })
					end, "Previous diagnostic")
					map("]d", function()
						vim.diagnostic.jump({ count = 1, float = true })
					end, "Next diagnostic")
					map("<leader>df", vim.diagnostic.open_float, "Line diagnostic")

					if client and client.server_capabilities.documentHighlightProvider then
						vim.api.nvim_clear_autocmds({ group = highlight_group, buffer = event.buf })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							group = highlight_group,
							buffer = event.buf,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter" }, {
							group = highlight_group,
							buffer = event.buf,
							callback = vim.lsp.buf.clear_references,
						})
						vim.api.nvim_create_autocmd("LspDetach", {
							group = highlight_group,
							buffer = event.buf,
							once = true,
							callback = function()
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = highlight_group, buffer = event.buf })
							end,
						})
					end
				end,
			})

			local servers = {
				lua_ls = {
					settings = {
						Lua = {
							diagnostics = { globals = { "vim" } },
							workspace = {
								library = vim.api.nvim_get_runtime_file("", true),
								checkThirdParty = false,
							},
						},
					},
				},
				clangd = {
					filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
					before_init = use_standard_position_encodings,
				},
				gopls = {
					root_dir = function(bufnr, on_dir)
						local root = vim.fs.root(bufnr, { "go.work", "go.mod", ".git" })
						if root then
							on_dir(root)
						end
					end,
					settings = {
						gopls = {
							gofumpt = true,
							usePlaceholders = true,
							completeUnimported = true,
						},
					},
				},
			}

			for name, config in pairs(servers) do
				config.capabilities = capabilities
				vim.lsp.config(name, config)
			end
			vim.lsp.enable(enabled_servers())
		end,
	},
}
