vim.keymap.set('n', '<leader>ta', '<Cmd>ToggleAlternate<CR>')

require('Comment').setup{
  toggler = {
    ---Line-comment toggle keymap
    line = ',ll',
  },
  extra = {
    -- Add comment at the end of line
    eol = ',lA',
  },
}
