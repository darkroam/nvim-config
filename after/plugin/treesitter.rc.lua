local languages = require("darkroam.languages")

local parser_specs = {
	lua = { parsers = { "lua" }, filetypes = { "lua" } },
	c = { parsers = { "c" }, filetypes = { "c" } },
	elisp = { parsers = { "commonlisp" }, filetypes = { "lisp" } },
	go = { parsers = { "go", "gomod", "gosum", "gowork" }, filetypes = { "go", "gomod", "gosum", "gowork" } },
}

local parser_order = { "lua", "c", "elisp", "go" }

local function enabled_parsers()
	local parsers = {}
	for _, name in ipairs(parser_order) do
		if languages.syntax[name] and parser_specs[name] then
			vim.list_extend(parsers, parser_specs[name].parsers)
		end
	end
	return parsers
end

local function enabled_filetypes()
	local filetypes = {}
	for _, name in ipairs(parser_order) do
		if languages.syntax[name] and parser_specs[name] then
			vim.list_extend(filetypes, parser_specs[name].filetypes)
		end
	end
	return filetypes
end

local ok_configs, treesitter_configs = pcall(require, "nvim-treesitter.configs")
if ok_configs then
	treesitter_configs.setup({
		ensure_installed = enabled_parsers(),
		sync_install = false,
		auto_install = false,
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = false,
		},
		indent = {
			enable = true,
		},
		textobjects = {
			select = {
				enable = true,
				lookahead = true,
				keymaps = {
					["af"] = "@function.outer",
					["if"] = "@function.inner",
				},
			},
		},
	})
	return
end

local ok_treesitter, treesitter = pcall(require, "nvim-treesitter")
if not ok_treesitter then
	return
end

treesitter.setup({})

vim.treesitter.language.register("commonlisp", "lisp")
vim.api.nvim_create_autocmd("FileType", {
	pattern = enabled_filetypes(),
	callback = function()
		pcall(vim.treesitter.start)
	end,
})
