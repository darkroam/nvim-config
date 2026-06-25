local ok_conform, conform = pcall(require, "conform")
local languages = require("darkroam.languages")

if not ok_conform then
	return
end

local formatters_by_ft = {}

if languages.syntax.lua then
	formatters_by_ft.lua = { "stylua" }
end

if languages.syntax.c then
	formatters_by_ft.c = { "clang_format" }
end

if languages.syntax.go then
	formatters_by_ft.go = { "gofmt" }
end

conform.setup({
	formatters_by_ft = formatters_by_ft,
	format_on_save = {
		timeout_ms = 500,
		lsp_fallback = true,
	},
})