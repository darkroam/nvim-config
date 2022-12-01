vim.opt.cursorline = true -- highlight the current line
vim.opt.termguicolors = true -- set term gui colors (most terminals support this)
vim.opt.winblend = 0
vim.opt.wildoptions = "pum"
vim.opt.pumblend = 5
vim.opt.background = "dark"

-- alternation 1:
-- vim.cmd('colorscheme everforest')

-- alternation 2:
-- local colorscheme = "aurora"
-- local colorscheme = "tokyonight"
local colorscheme = "neosolarized"
local status, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status then
	vim.notify("colorscheme " .. colorscheme .. " not found!")
	return
end
