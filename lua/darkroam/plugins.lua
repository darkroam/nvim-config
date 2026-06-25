local fn = vim.fn

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
	print("Installing packer; close and reopen Neovim, then run :PackerSync")
	vim.cmd([[packadd packer.nvim]])
end

local status, packer = pcall(require, "packer")
if not status then
	print("Packer is not installed")
	return
end

packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

return packer.startup(function(use)
	use("wbthomason/packer.nvim")
	use("nvim-lua/plenary.nvim")
	use("nvim-lua/popup.nvim")

	-- Editing basics
	use("windwp/nvim-autopairs")
	use("wellle/targets.vim")
	use("mg979/vim-visual-multi")
	use("numToStr/Comment.nvim")
	use("kylechui/nvim-surround")
	use("rmagatti/alternate-toggler")

	-- UI
	use("nvim-tree/nvim-web-devicons")
	use("nvim-tree/nvim-tree.lua")
	use("akinsho/nvim-bufferline.lua")
	use("akinsho/toggleterm.nvim")
	use("folke/zen-mode.nvim")
	use("lewis6991/impatient.nvim")
	use({ "svrana/neosolarized.nvim", requires = { "tjdevries/colorbuddy.nvim" } })
	use("nvim-lualine/lualine.nvim")

	-- Completion
	use("hrsh7th/nvim-cmp")
	use("hrsh7th/cmp-buffer")
	use("hrsh7th/cmp-path")
	use("hrsh7th/cmp-cmdline")
	use("hrsh7th/cmp-nvim-lsp")
	use("hrsh7th/cmp-nvim-lua")
	use("saadparwaiz1/cmp_luasnip")
	use("L3MON4D3/LuaSnip")
	use("rafamadriz/friendly-snippets")

	-- LSP: only Lua and Go are configured.
	use("neovim/nvim-lspconfig")
	use("williamboman/mason.nvim")
	use("williamboman/mason-lspconfig.nvim")
	use("RRethy/vim-illuminate")

	-- Telescope
	use("nvim-telescope/telescope.nvim")
	use("nvim-telescope/telescope-file-browser.nvim")
	use("ahmedkhalf/project.nvim")

	-- Treesitter: parsers are restricted in after/plugin/treesitter.rc.lua.
	use({
		"nvim-treesitter/nvim-treesitter",
		run = function()
			require("nvim-treesitter.install").update({ with_sync = true })
		end,
	})
	use("nvim-treesitter/nvim-treesitter-textobjects")

	-- Git
	use("lewis6991/gitsigns.nvim")

	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)

