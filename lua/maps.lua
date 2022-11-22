local keymap = vim.keymap

keymap.set('i', 'kj', '<ESC>')

-- Do not yank with x
keymap.set('n', 'x', '"_x')

-- Increment/Decrement for Number
keymap.set('n', '+', '<C-a>')
keymap.set('n', '-', '<C-x>')

-- Delete a word backwards
-- keymap.set('n', 'dw', 'vb"_d')

-- Select all
keymap.set('n', '<C-a>', 'gg<S-v>G')

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
keymap.set('', 's<left>', '<C-w>h')
keymap.set('', 's<down>', '<C-w>j')
keymap.set('', 's<up>', '<C-w>k')
keymap.set('', 's<right>', '<C-w>l')
keymap.set('', 'sh', '<C-w>h')
keymap.set('', 'sj', '<C-w>j')
keymap.set('', 'sk', '<C-w>k')
keymap.set('', 'sl', '<C-w>l')

-- Resize window
keymap.set('n', '<C-w><left>', '<C-w><')
keymap.set('n', '<C-w><right>', '<C-w>>')
keymap.set('n', '<C-w><up>', '<C-w>+')
keymap.set('n', '<C-w><down>', '<C-w>-')
