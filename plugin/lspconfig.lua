local ok_cmp_lsp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
local languages = require("darkroam.languages")
local capabilities = vim.lsp.protocol.make_client_capabilities()
if ok_cmp_lsp then
	capabilities = cmp_lsp.default_capabilities(capabilities)
end

local function on_attach(client, bufnr)
	if client.name == "lua_ls" then
		client.server_capabilities.documentFormattingProvider = false
	end

	local function map(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
	end

	map("n", "gD", vim.lsp.buf.declaration, "LSP declaration")
	map("n", "gd", vim.lsp.buf.definition, "LSP definition")
	map("n", "gi", vim.lsp.buf.implementation, "LSP implementation")
	map("n", "gr", vim.lsp.buf.references, "LSP references")
	map("n", "K", vim.lsp.buf.hover, "LSP hover")
	map("n", "<leader>rn", vim.lsp.buf.rename, "LSP rename")
	map("n", "<leader>ca", vim.lsp.buf.code_action, "LSP code action")
	map("n", "<leader>lf", function()
		vim.lsp.buf.format({ async = true })
	end, "LSP format")
	map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
	map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
	map("n", "<leader>e", vim.diagnostic.open_float, "Line diagnostic")

	local ok_illuminate, illuminate = pcall(require, "illuminate")
	if ok_illuminate then
		illuminate.on_attach(client)
	end
end

vim.diagnostic.config({
	virtual_text = { prefix = "●" },
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = "always",
	},
})

for type, icon in pairs({ Error = "E", Warn = "W", Hint = "H", Info = "I" }) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

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
	clangd = {},
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

local enabled_servers = {}
if languages.syntax.lua then
	table.insert(enabled_servers, "lua_ls")
end
if languages.syntax.c then
	table.insert(enabled_servers, "clangd")
end
if languages.syntax.go then
	table.insert(enabled_servers, "gopls")
end

for name, config in pairs(servers) do
	config.capabilities = capabilities
	config.on_attach = on_attach
	vim.lsp.config(name, config)
end

vim.lsp.enable(enabled_servers)
