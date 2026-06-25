local ok_mason, mason = pcall(require, "mason")
if not ok_mason then
	return
end

local ok_mason_lspconfig, mason_lspconfig = pcall(require, "mason-lspconfig")
if not ok_mason_lspconfig then
	return
end

mason.setup({})

mason_lspconfig.setup({
	ensure_installed = { "lua_ls", "gopls" },
	automatic_installation = false,
})
