local status, telescope = pcall(require, "telescope")
if not status then
	return
end
local actions = require("telescope.actions")
local builtin = require("telescope.builtin")

local function telescope_buffer_dir()
	return vim.fn.expand("%:p:h")
end

local fb_actions = require("telescope").extensions.file_browser.actions

telescope.setup({
	defaults = {

		prompt_prefix = " ",
		selection_caret = " ",
		path_display = { "smart" },

		mappings = {
			-- i = {
			--   ["<C-n>"] = actions.cycle_history_next,
			--   ["<C-p>"] = actions.cycle_history_prev,
			--
			--   ["<C-j>"] = actions.move_selection_next,
			--   ["<C-k>"] = actions.move_selection_previous,
			--
			--   ["<C-c>"] = actions.close,
			--
			--   ["<Down>"] = actions.move_selection_next,
			--   ["<Up>"] = actions.move_selection_previous,
			--
			--   ["<CR>"] = actions.select_default,
			--   ["<C-x>"] = actions.select_horizontal,
			--   ["<C-v>"] = actions.select_vertical,
			--   ["<C-t>"] = actions.select_tab,
			--
			--   ["<C-u>"] = actions.preview_scrolling_up,
			--   ["<C-d>"] = actions.preview_scrolling_down,
			--
			--   ["<PageUp>"] = actions.results_scrolling_up,
			--   ["<PageDown>"] = actions.results_scrolling_down,
			--
			--   ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
			--   ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
			--   ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
			--   ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
			--   ["<C-l>"] = actions.complete_tag,
			--   ["<C-_>"] = actions.which_key, -- keys from pressing <C-/>
			-- },

			n = {
				["q"] = actions.close,
				-- ["<esc>"] = actions.close,
				-- ["<CR>"] = actions.select_default,
				-- ["<C-x>"] = actions.select_horizontal,
				-- ["<C-v>"] = actions.select_vertical,
				-- ["<C-t>"] = actions.select_tab,
				--
				-- ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
				-- ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
				-- ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
				-- ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
				--
				-- ["j"] = actions.move_selection_next,
				-- ["k"] = actions.move_selection_previous,
				-- ["H"] = actions.move_to_top,
				-- ["M"] = actions.move_to_middle,
				-- ["L"] = actions.move_to_bottom,
				--
				-- ["<Down>"] = actions.move_selection_next,
				-- ["<Up>"] = actions.move_selection_previous,
				-- ["gg"] = actions.move_to_top,
				-- ["G"] = actions.move_to_bottom,
				--
				-- ["<C-u>"] = actions.preview_scrolling_up,
				-- ["<C-d>"] = actions.preview_scrolling_down,
				--
				-- ["<PageUp>"] = actions.results_scrolling_up,
				-- ["<PageDown>"] = actions.results_scrolling_down,

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
			-- theme : "ivy" "dropdown" "cursor"
			theme = "dropdown",
			-- disables netrw and use telescope-file-browser in its place
			hijack_netrw = false,
			mappings = {
				-- your custom insert mode mappings
				["i"] = {
					["<C-w>"] = function()
						vim.cmd("normal vbd")
					end,
				},
				["n"] = {
					-- your custom normal mode mappings
					["N"] = fb_actions.create,
					["h"] = fb_actions.goto_parent_dir,
					["/"] = function()
						vim.cmd("startinsert")
					end,
				},
			},
		},
	},
})

telescope.load_extension("file_browser")

vim.keymap.set("n", ",rr", function()
	builtin.find_files({
		no_ignore = false,
		hidden = true,
	})
end)
vim.keymap.set("n", ",dd", function()
	builtin.live_grep()
end)
vim.keymap.set("n", ",bb", function()
	builtin.buffers()
end)
vim.keymap.set("n", ";t", function()
	builtin.help_tags()
end)
vim.keymap.set("n", ";;", function()
	builtin.resume()
end)
vim.keymap.set("n", ";e", function()
	builtin.diagnostics()
end)
vim.keymap.set("n", ",kk", function()
	builtin.keymaps()
end)
vim.keymap.set("n", ",xf", function()
	telescope.extensions.file_browser.file_browser({
		path = "%:p:h",
		cwd = telescope_buffer_dir(),
		respect_gitignore = false,
		hidden = true,
		grouped = true,
		previewer = false,
		initial_mode = "normal",
		layout_config = { height = 40 },
	})
end)
