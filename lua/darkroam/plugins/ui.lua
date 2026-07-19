return {
	{
		"nvim-tree/nvim-web-devicons",
		lazy = true,
		opts = {
			override = {},
			default = true,
		},
	},
	{
		"svrana/neosolarized.nvim",
		lazy = false,
		priority = 1000,
		dependencies = { "tjdevries/colorbuddy.nvim" },
		config = function()
			vim.opt.cursorline = true
			vim.opt.termguicolors = true
			vim.opt.winblend = 0
			vim.opt.wildoptions = "pum"
			vim.opt.pumblend = 5
			vim.opt.background = "dark"

			require("neosolarized").setup({
				comment_italics = true,
			})
			vim.cmd.colorscheme("neosolarized")

			local colorbuddy = require("colorbuddy.init")
			local Color = colorbuddy.Color
			local colors = colorbuddy.colors
			local Group = colorbuddy.Group
			local groups = colorbuddy.groups
			local styles = colorbuddy.styles

			Color.new("black", "#000000")
			Group.new("CursorLine", colors.none, colors.base03, styles.NONE, colors.base1)
			Group.new("CursorLineNr", colors.yellow, colors.black, styles.NONE, colors.base1)
			Group.new("Visual", colors.none, colors.base03, styles.reverse)

			local error_color = groups.Error.fg
			local info_color = groups.Information.fg
			local warn_color = groups.Warning.fg
			local hint_color = groups.Hint.fg

			Group.new("DiagnosticVirtualTextError", error_color, error_color:dark():dark():dark():dark(), styles.NONE)
			Group.new("DiagnosticVirtualTextInfo", info_color, info_color:dark():dark():dark(), styles.NONE)
			Group.new("DiagnosticVirtualTextWarn", warn_color, warn_color:dark():dark():dark(), styles.NONE)
			Group.new("DiagnosticVirtualTextHint", hint_color, hint_color:dark():dark():dark(), styles.NONE)
			Group.new("DiagnosticUnderlineError", colors.none, colors.none, styles.undercurl, error_color)
			Group.new("DiagnosticUnderlineWarn", colors.none, colors.none, styles.undercurl, warn_color)
			Group.new("DiagnosticUnderlineInfo", colors.none, colors.none, styles.undercurl, info_color)
			Group.new("DiagnosticUnderlineHint", colors.none, colors.none, styles.undercurl, hint_color)
		end,
	},
	{
		"nvim-tree/nvim-tree.lua",
		cmd = {
			"NvimTreeOpen",
			"NvimTreeClose",
			"NvimTreeToggle",
			"NvimTreeFocus",
			"NvimTreeFindFile",
		},
		keys = {
			{ "<leader>e", "<Cmd>NvimTreeToggle<CR>", desc = "Toggle file tree" },
		},
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			disable_netrw = true,
			hijack_netrw = true,
			update_focused_file = { enable = true },
			view = { width = 30, side = "left" },
			renderer = {
				highlight_git = true,
				icons = { show = { file = true, folder = true, folder_arrow = true, git = true } },
			},
			git = { enable = true, ignore = false },
			diagnostics = { enable = true },
		},
	},
	{
		"akinsho/nvim-bufferline.lua",
		event = "VeryLazy",
		keys = {
			{ "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
			{ "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Previous tab" },
		},
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("bufferline").setup({
				options = {
					mode = "tabs",
					separator_style = "slant",
					always_show_bufferline = false,
					show_buffer_close_icons = false,
					show_close_icon = false,
					color_icons = true,
				},
				highlights = {
					separator = { fg = "#073642", bg = "#002b36" },
					separator_selected = { fg = "#073642" },
					indicator_selected = { fg = "#77BBFF" },
					background = { fg = "#657b83", bg = "#002b36" },
					buffer_selected = { fg = "#fdf6e3", bold = true },
					fill = { bg = "#073642" },
				},
			})
		end,
	},
	{
		"akinsho/toggleterm.nvim",
		cmd = { "ToggleTerm", "TermExec" },
		keys = {
			{ "<leader>xc", "<Cmd>ToggleTerm<CR>", mode = { "n", "i" }, desc = "Toggle terminal" },
		},
		config = function()
			require("toggleterm").setup({
				size = 20,
				hide_numbers = true,
				shade_filetypes = {},
				shade_terminals = true,
				shading_factor = 2,
				start_in_insert = true,
				insert_mappings = false,
				terminal_mappings = false,
				persist_size = true,
				persist_mode = true,
				direction = "float",
				close_on_exit = true,
				shell = vim.o.shell,
				float_opts = {
					border = "curved",
					winblend = 0,
					highlights = {
						border = "Normal",
						background = "Normal",
					},
				},
			})

			local terminal_group = vim.api.nvim_create_augroup("DarkroamToggleTerm", { clear = true })
			vim.api.nvim_create_autocmd("TermOpen", {
				group = terminal_group,
				pattern = "term://*toggleterm#*",
				callback = function(event)
					local opts = { buffer = event.buf, silent = true }
					vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)
					vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
					vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
					vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
					vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
				end,
			})
		end,
	},
	{
		"folke/zen-mode.nvim",
		cmd = "ZenMode",
		keys = {
			{ "<leader>ff", "<Cmd>ZenMode<CR>", desc = "Toggle ZenMode" },
		},
		opts = {},
	},
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					icons_enabled = true,
					theme = "codedark",
					section_separators = { left = "", right = "" },
					component_separators = { left = "", right = "" },
					disabled_filetypes = {},
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch" },
					lualine_c = {
						{ "filename", file_status = true, path = 0 },
					},
					lualine_x = {
						{
							"diff",
							colored = true,
							symbols = { added = " ", modified = " ", removed = " " },
						},
						{
							"diagnostics",
							sources = { "nvim_diagnostic" },
							symbols = { error = " ", warn = " ", info = " ", hint = " " },
						},
						"encoding",
						"filetype",
					},
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = { { "filename", file_status = true, path = 1 } },
					lualine_x = { "location" },
					lualine_y = {},
					lualine_z = {},
				},
				tabline = {},
				extensions = {},
			})
		end,
	},
}
