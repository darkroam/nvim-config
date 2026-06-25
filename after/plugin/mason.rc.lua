local ok_mason, mason = pcall(require, "mason")
local languages = require("darkroam.languages")
if not ok_mason then
	return
end

local ok_mason_lspconfig, mason_lspconfig = pcall(require, "mason-lspconfig")
if not ok_mason_lspconfig then
	return
end

mason.setup({})

local ensure_installed = {}
if languages.syntax.lua then
	table.insert(ensure_installed, "lua_ls")
end
if languages.syntax.c then
	table.insert(ensure_installed, "clangd")
end
if languages.syntax.go then
	table.insert(ensure_installed, "gopls")
end

mason_lspconfig.setup({
	ensure_installed = ensure_installed,
	automatic_installation = false,
})
