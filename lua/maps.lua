local keymap = vim.keymap

vim.g.mapleader = ","

keymap.set('i', 'kj', '<ESC>')
keymap.set('n', ',xc', '<Cmd>q<CR>')
keymap.set('n', ',xs', '<Cmd>w<CR>')

-- Do not yank with x
keymap.set('n', 'x', '"_x')

-- Increment/Decrement for Number
keymap.set('n', '+', '<C-a>')
keymap.set('n', '-', '<C-x>')

-- Delete a word backwards
-- keymap.set('n', 'dw', 'vb"_d')

-- Select all
keymap.set('n', '<C-a>', 'gg<S-v>G')

-- Save with root permission (not working for now)
--vim.api.nvim_create_user_command('W', 'w !sudo tee > /dev/null %', {})

-- New tab
keymap.set('n', 'te', ':tabedit<Return>', { silent = true })
-- Split windows
keymap.set('n', ',x2', ':split<Return><C-w>w', { silent = true })
keymap.set('n', ',x3', ':vsplit<Return><C-w>w', { silent = true })
keymap.set('n', 'ss', ':split<Return><C-w>w', { silent = true })
keymap.set('n', 'sv', ':vsplit<Return><C-w>w', { silent = true })
-- Move windows
keymap.set('n', ',xo', '<C-w>w')
keymap.set('', ',wh', '<C-w>h')
keymap.set('', ',wj', '<C-w>j')
keymap.set('', ',wk', '<C-w>k')
keymap.set('', ',wl', '<C-w>l')
keymap.set('n', '<Space>', '<C-w>w')
keymap.set('', 'sh', '<C-w>h')
keymap.set('', 'sj', '<C-w>j')
keymap.set('', 'sk', '<C-w>k')
keymap.set('', 'sl', '<C-w>l')

-- Resize window
keymap.set('n', ',s<left>', '<C-w><')
keymap.set('n', ',s<right>', '<C-w>>')
keymap.set('n', ',s<up>', '<C-w>+')
keymap.set('n', ',s<down>', '<C-w>-')
