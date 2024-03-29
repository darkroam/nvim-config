local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
	print("Installing packer close and reopen Neovim...")
	vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
-- vim.cmd([[
--   augroup packer_user_config
--   autocmd!
--   autocmd BufWritePost plugins.lua source <afile> | PackerSync
--   augroup end
-- ]])

-- Use a protected call so we don't error out on first use
local status, packer = pcall(require, "packer")
if not status then
	print("Packer is not installed")
	return
end

-- vim.cmd([[packadd packer.nvim]])

-- Have packer use a popup window
packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

-- Install your plugins here
return packer.startup(function(use)
	use("wbthomason/packer.nvim")
	use("nvim-lua/popup.nvim") -- An implementation of the Popup API from vim in Neovim
	use("nvim-lua/plenary.nvim") -- Useful lua functions used ny lots of plugins -- Common utilities
	use("windwp/nvim-autopairs") -- Autopairs, integrates with both cmp and treesitter
	use("wellle/targets.vim") -- improve vim text objects function
	use("windwp/nvim-ts-autotag")
	use("mg979/vim-visual-multi") -- a powerful plugin for multi visual editor
	use("numToStr/Comment.nvim") -- Easily comment stuff
	use("nvim-tree/nvim-web-devicons") -- File icons
	use("nvim-tree/nvim-tree.lua") -- File icons
	-- use("terryma/vim-expand-region") -- A simple plugins for expand region, key binding '+'/'-'
	use("akinsho/nvim-bufferline.lua")
	use("rmagatti/alternate-toggler") -- A simple plugins for true/false toggler, key binding ',ta'
	use("akinsho/toggleterm.nvim") -- terminal plugins
	use("folke/zen-mode.nvim") -- full-screen plugins
	use("lewis6991/impatient.nvim") -- Speed up loading lua modules in Neovim to improve startup time
	use("kylechui/nvim-surround") -- Surround selections

	-- Colorschemes
	-- use("lunarvim/colorschemes") -- A bunch of colorschemes you can try out
	-- use("lunarvim/darkplus.nvim")
	-- use("folke/tokyonight.nvim") -- A bunch of colorschemes you can try out
	-- use("sainnhe/everforest")
	use({
		"svrana/neosolarized.nvim",
		requires = { "tjdevries/colorbuddy.nvim" },
	})
	use("nvim-lualine/lualine.nvim") -- Statusline
	use("norcalli/nvim-colorizer.lua") -- Color Highlighter plugins

	-- cmp plugins
	use("hrsh7th/nvim-cmp") -- The completion plugin
	use("hrsh7th/cmp-buffer") -- nvim-cmp source for buffer words
	use("hrsh7th/cmp-path") -- path completions
	use("hrsh7th/cmp-cmdline") -- cmdline completions
	use("hrsh7th/cmp-nvim-lsp") -- nvim-cmp source for neovim's built-in LSP
	use("hrsh7th/cmp-nvim-lua") -- nvim-cmp source for lua
	use("saadparwaiz1/cmp_luasnip") -- snippet completions
	-- use("onsails/lspkind-nvim") -- vscode-like pictograms

	-- snippets
	use("L3MON4D3/LuaSnip") -- sinppet engine; cmp.nvim need a snippet engine to work.
	use("rafamadriz/friendly-snippets") -- a bunch of snippets to use

	-- LSP
	use("neovim/nvim-lspconfig") -- enable LSP
	use("williamboman/mason.nvim") -- simple to use language server installer
	use("williamboman/mason-lspconfig.nvim") -- simple to use language server installer
	use("jose-elias-alvarez/null-ls.nvim") -- Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua.
	use("glepnir/lspsaga.nvim") -- LSP UIs
	use("RRethy/vim-illuminate")
	-- use("MunifTanjim/prettier.nvim") -- Prettier plugin for Neovim's build-in LSP client_source_map

	-- Telescope
	use("nvim-telescope/telescope.nvim")
	use("nvim-telescope/telescope-file-browser.nvim")
	use("ahmedkhalf/project.nvim") -- for projects

	-- Treesitter
	use({
		"nvim-treesitter/nvim-treesitter",
		run = function()
			require("nvim-treesitter.install").update({ with_sync = true })
		end,
	})
	use("p00f/nvim-ts-rainbow")
	use("JoosepAlviste/nvim-ts-context-commentstring")
	use("nvim-treesitter/nvim-treesitter-textobjects")
	-- use("nvim-treesitter/playground")

	-- Git
	use("lewis6991/gitsigns.nvim")
	-- use("dinhhuy258/git.nvim") -- For git blame & browser
	use({ "TimUntersberger/neogit", requires = "nvim-lua/plenary.nvim" })

	-- Text Format , org, markdown, etc.
	use("nvim-orgmode/orgmode")
	use("akinsho/org-bullets.nvim")
	use({
		"iamcco/markdown-preview.nvim",
		run = function()
			vim.fn["mkdp#util#install"]()
		end,
	})
	use("allen-mack/nvim-table-md")

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
