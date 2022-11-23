vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.winblend = 0
vim.opt.wildoptions = 'pum'
vim.opt.pumblend = 5
vim.opt.background = 'dark'

vim.api.nvim_create_autocmd ( 'TextYankPost', {
  callback = function ()
    vim.highlight.on_yank {
      higroup = 'IncSearch',
      timeout = 300
    }
  end
})

-- vim.cmd('colorscheme everforest')
