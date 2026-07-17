local compat = require("darkroam.compat")

return {
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		dependencies = { "hrsh7th/nvim-cmp" },
		config = function()
			local autopairs = require("nvim-autopairs")
			autopairs.setup({
				check_ts = compat.supports("treesitter"),
				ts_config = {
					lua = { "string", "source" },
					javascript = { "string", "template_string" },
					java = false,
				},
				disable_filetype = { "TelescopePrompt", "spectre_panel", "vim" },
				fast_wrap = {
					map = "<M-e>",
					chars = { "{", "[", "(", '"', "'" },
					pattern = string.gsub([[ [%'"%)%>%]%)%}%,] ]], "%s+", ""),
					offset = 0,
					end_key = "$",
					keys = "qwertyuiopzxcvbnmasdfghjkl",
					check_comma = true,
					highlight = "PmenuSel",
					highlight_grey = "LineNr",
				},
			})

			local cmp = require("cmp")
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))
		end,
	},
	{
		"wellle/targets.vim",
		lazy = false,
	},
	{
		"mg979/vim-visual-multi",
		lazy = false,
	},
	{
		"numToStr/Comment.nvim",
		event = "VeryLazy",
		opts = {
			toggler = {
				line = ",ll",
			},
			opleader = {
				line = ",l",
			},
			extra = {
				above = ",lO",
				eol = ",lA",
			},
		},
	},
	{
		"kylechui/nvim-surround",
		event = "VeryLazy",
		opts = {},
	},
	{
		"rmagatti/alternate-toggler",
		keys = {
			{ "<leader>ta", "<Cmd>ToggleAlternate<CR>", desc = "Toggle alternate value" },
		},
	},
}
