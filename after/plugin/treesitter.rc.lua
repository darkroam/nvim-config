local status, ts = pcall(require, "nvim-treesitter.configs")
if not status then
	return
end

ts.setup({
	highlight = {
		enable = true, -- false will disable the whole extension
		disable = { "" }, -- list of language that will be disabled
		additional_vim_regex_highlighting = true,
	},
	indent = {
		enable = true,
		disable = {},
	},
	-- ensure_installed = "all", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
	ensure_installed = {
		"fish",
		"json",
		"yaml",
		"html",
		"lua",
		"python",
		"rust",
		"go",
		"vim",
		"org",
		"markdown",
	},
	sync_install = false, -- install languages synchronously (only applied to 'ensure_installed')
	ignore_install = { "" }, -- List of parsers to ignore installing
	-- for plugin("nvim-autopairs")
	autopairs = {
		enable = true,
	},
	autotag = {
		enable = true,
	},
	-- for plugin("nvim-ts-rainbow")
	rainbow = {
		enable = true,
		-- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
		extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
		max_file_lines = nil, -- Do not enable for files with more than n lines, int
		-- colors = {}, -- table of hex strings
		-- termcolors = {} -- table of colour name strings
	},
	-- for plugin("nvim-ts-context-commentstring")
	context_commentstring = {
		enable = true,
		enable_autocmd = false,
	},
	-- for plugin("playground")
	-- playground = {
	--   enable = true,
	-- },
})

local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.tsx.filetype_to_parsername = { "javascript", "typescript.tsx" }
