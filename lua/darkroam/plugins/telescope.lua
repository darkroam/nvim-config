local compat = require("darkroam.compat")

local telescope_enabled = function()
	return compat.supports("telescope")
end

return {
	{
		"nvim-telescope/telescope.nvim",
		cond = telescope_enabled,
		cmd = "Telescope",
		keys = {
			{
				",rr",
				function()
					require("telescope.builtin").find_files({ no_ignore = false, hidden = true })
				end,
				desc = "Find files",
			},
			{
				",dd",
				function()
					require("telescope.builtin").live_grep()
				end,
				desc = "Live grep",
			},
			{
				",bb",
				function()
					require("telescope.builtin").buffers()
				end,
				desc = "Find buffers",
			},
			{
				";t",
				function()
					require("telescope.builtin").help_tags()
				end,
				desc = "Help tags",
			},
			{
				";;",
				function()
					require("telescope.builtin").resume()
				end,
				desc = "Resume Telescope",
			},
			{
				";e",
				function()
					require("telescope.builtin").diagnostics()
				end,
				desc = "Diagnostics",
			},
			{
				",kk",
				function()
					require("telescope.builtin").keymaps()
				end,
				desc = "Keymaps",
			},
			{
				",xf",
				function()
					require("telescope").extensions.file_browser.file_browser({
						path = "%:p:h",
						cwd = vim.fn.expand("%:p:h"),
						respect_gitignore = false,
						hidden = true,
						grouped = true,
						previewer = false,
						initial_mode = "normal",
						layout_config = { height = 40 },
					})
				end,
				desc = "File browser",
			},
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"nvim-telescope/telescope-file-browser.nvim",
		},
		config = function()
			local telescope = require("telescope")
			local actions = require("telescope.actions")
			local file_browser_actions = require("telescope").extensions.file_browser.actions

			telescope.setup({
				defaults = {
					prompt_prefix = " ",
					selection_caret = " ",
					path_display = { "smart" },
					mappings = {
						n = {
							q = actions.close,
							["?"] = actions.which_key,
						},
					},
				},
				layout_config = {
					horizontal = {
						preview_cutoff = 100,
						preview_width = 0.6,
					},
				},
				extensions = {
					file_browser = {
						theme = "dropdown",
						hijack_netrw = false,
						mappings = {
							i = {
								["<C-w>"] = function()
									vim.cmd("normal vbd")
								end,
							},
							n = {
								N = file_browser_actions.create,
								h = file_browser_actions.goto_parent_dir,
								["/"] = function()
									vim.cmd.startinsert()
								end,
							},
						},
					},
				},
			})

			telescope.load_extension("file_browser")
		end,
	},
}
