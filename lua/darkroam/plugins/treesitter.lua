local compat = require("darkroam.compat")
local languages = require("darkroam.languages")
local install_dir = vim.fn.stdpath("data") .. "/treesitter-0.12"

local parser_specs = {
	lua = { parsers = { "lua" }, filetypes = { "lua" } },
	c = { parsers = { "c" }, filetypes = { "c" } },
	elisp = { parsers = { "commonlisp" }, filetypes = { "lisp" } },
	go = {
		parsers = { "go", "gomod", "gosum", "gowork" },
		filetypes = { "go", "gomod", "gosum", "gowork" },
	},
}

local parser_order = { "lua", "c", "elisp", "go" }

local function enabled_values(key)
	local values = {}
	for _, language in ipairs(parser_order) do
		if languages.syntax[language] and parser_specs[language] then
			vim.list_extend(values, parser_specs[language][key])
		end
	end
	return values
end

local treesitter_enabled = function()
	return compat.supports("treesitter")
end

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		cond = treesitter_enabled,
		lazy = false,
		build = ":TSUpdate",
		dependencies = {
			{
				"nvim-treesitter/nvim-treesitter-textobjects",
				branch = "main",
				cond = treesitter_enabled,
			},
		},
		config = function()
			require("nvim-treesitter").setup({
				install_dir = install_dir,
			})
			vim.api.nvim_create_user_command("DarkroamTSInstall", function()
				require("nvim-treesitter").install(enabled_values("parsers"))
			end, { desc = "Install parsers selected by darkroam.languages" })

			vim.treesitter.language.register("commonlisp", "lisp")
			local treesitter_group = vim.api.nvim_create_augroup("DarkroamTreesitter", { clear = true })
			vim.api.nvim_create_autocmd("FileType", {
				group = treesitter_group,
				pattern = enabled_values("filetypes"),
				callback = function(event)
					if pcall(vim.treesitter.start, event.buf) then
						vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})

			require("nvim-treesitter-textobjects").setup({
				select = {
					lookahead = true,
					selection_modes = {
						["@function.outer"] = "V",
					},
					include_surrounding_whitespace = false,
				},
			})

			local select_textobject = require("nvim-treesitter-textobjects.select").select_textobject
			vim.keymap.set({ "x", "o" }, "af", function()
				select_textobject("@function.outer", "textobjects")
			end, { desc = "Select outer function" })
			vim.keymap.set({ "x", "o" }, "if", function()
				select_textobject("@function.inner", "textobjects")
			end, { desc = "Select inner function" })
		end,
	},
}
