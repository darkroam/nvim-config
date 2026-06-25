local ok, nvim_tree = pcall(require, "nvim-tree")
if not ok then
	return
end

nvim_tree.setup({
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
})
