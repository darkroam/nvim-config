-- vim.scriptencoding = "utf-8"
vim.opt.path:append({ "**" }) -- Finding files - Search down into subfolders
vim.opt.wildignore:append({ "*/node_modules/*" })
vim.opt.shortmess:append("c")
local automatic_comment_formatoptions = { "c", "r", "o" }
vim.opt.formatoptions:remove(automatic_comment_formatoptions)

local is_windows = vim.fn.has("win32") == 1
local shell = "zsh"
if is_windows then
	local powershell = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell"
	local shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command "
		.. "[Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();"
		.. "$PSDefaultParameterValues['Out-File:Encoding']='utf8';"
	if powershell == "pwsh" then
		shellcmdflag = shellcmdflag .. "$PSStyle.OutputRendering='PlainText';"
	end

	shell = powershell
	vim.opt.shelltemp = false
	vim.opt.shellcmdflag = shellcmdflag
	vim.opt.shellpipe = "> %s 2>&1"
	vim.opt.shellredir = "> %s 2>&1"
	vim.opt.shellquote = ""
	vim.opt.shellxquote = ""
end

local options = {
	-- title = true,
	backup = false, -- creates a backup file
	backupskip = { "/tmp/*", "/private/tmp/*" },
	backspace = { "start", "eol", "indent" },
	shell = shell,
	showcmd = true,
	clipboard = "unnamedplus", -- allows neovim to access the system clipboard
	cmdheight = 2, -- more space in the neovim command line for displaying messages
	laststatus = 2,
	completeopt = { "menuone", "noselect" }, -- mostly just for cmp
	conceallevel = 0, -- so that `` is visible in markdown files
	encoding = "utf-8",
	fileencoding = "utf-8", -- the encoding written to a file
	hlsearch = true, -- highlight all matches on previous search pattern
	incsearch = true,
	inccommand = "split",
	ignorecase = true, -- ignore case in search patterns
	mouse = "a", -- allow the mouse to be used in neovim
	pumheight = 10, -- pop up menu height
	showmode = false, -- we don't need to see things like -- INSERT -- anymore
	showtabline = 2, -- always show tabs
	smartcase = true, -- smart case
	smartindent = true, -- make indenting smarter again
	autoindent = true,
	splitbelow = true, -- force all horizontal splits to go below current window
	splitright = true, -- force all vertical splits to go to the right of current window
	swapfile = false, -- creates a swapfile
	termguicolors = true, -- set term gui colors (most terminals support this)
	timeoutlen = 1000, -- time to wait for a mapped sequence to complete (in milliseconds)
	undofile = true, -- enable persistent undo
	updatetime = 300, -- faster completion (4000ms default)
	writebackup = false, -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
	expandtab = true, -- convert tabs to spaces
	smarttab = true,
	breakindent = true,
	shiftwidth = 2, -- the number of spaces inserted for each indentation
	tabstop = 2, -- insert 2 spaces for a tab
	softtabstop = 2,
	cursorline = true, -- highlight the current line
	number = true, -- set numbered lines
	relativenumber = true, -- set relative numbered lines
	numberwidth = 4, -- set number column width to 2 {default 4}
	signcolumn = "yes", -- always show the sign column, otherwise it would shift the text each time
	wrap = true, -- display lines as one long line
	linebreak = true, -- companion to wrap, don't split words
	scrolloff = 8, -- minimal number of screen lines to keep above and below the cursor
	sidescrolloff = 8, -- minimal number of screen columns either side of cursor if wrap is `false`
	guifont = "monospace:h17", -- the font used in graphical neovim applications
}

for k, v in pairs(options) do
	vim.opt[k] = v
end

vim.cmd("set whichwrap+=<,>,[,],h,l")
vim.cmd([[set iskeyword+=-]])

-- Undercurl
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

local options_group = vim.api.nvim_create_augroup("DarkroamOptions", { clear = true })

-- Filetype plugins may restore automatic comment wrapping and continuation.
vim.api.nvim_create_autocmd("FileType", {
	group = options_group,
	pattern = "*",
	callback = function()
		vim.opt_local.formatoptions:remove(automatic_comment_formatoptions)
	end,
})

-- Turn off paste mode when leaving insert
vim.api.nvim_create_autocmd("InsertLeave", {
	group = options_group,
	pattern = "*",
	command = "set nopaste",
})

vim.api.nvim_create_autocmd("TextYankPost", {
	group = options_group,
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",
			timeout = 300,
		})
	end,
})
