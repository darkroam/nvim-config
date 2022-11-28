local opts = { noremap = true, silent = true }

local term_opts = { silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal --
-- New tab
keymap('n', 'te', ':tabedit<Return>', term_opts)

-- Move windows navigation
keymap('n', '<leader>xo', '<C-w>w', opts)
keymap('n', '<leader>wh', '<C-w>h', opts)
keymap('n', '<leader>wj', '<C-w>j', opts)
keymap('n', '<leader>wk', '<C-w>k', opts)
keymap('n', '<leader>wl', '<C-w>l', opts)
keymap('n', '<Space>', '<C-w>w', opts)
keymap('n', 'sh', '<C-w>h', opts)
keymap('n', 'sj', '<C-w>j', opts)
keymap('n', 'sk', '<C-w>k', opts)
keymap('n', 'sl', '<C-w>l', opts)
-- keymap("n", "<C-h>", "<C-w>h", opts)
-- keymap("n", "<C-j>", "<C-w>j", opts)
-- keymap("n", "<C-k>", "<C-w>k", opts)
-- keymap("n", "<C-l>", "<C-w>l", opts)

keymap("n", "<leader>e", ":Lex 30<cr>", opts)

-- Split windows
keymap('n', '<leader>x2', ':split<Return><C-w>w', term_opts)
keymap('n', '<leader>x3', ':vsplit<Return><C-w>w', term_opts)
keymap('n', 'ss', ':split<Return><C-w>w', term_opts)
keymap('n', 'sv', ':vsplit<Return><C-w>w', term_opts)

-- Resize with arrows

-- Resize window
-- keymap('n', ',s<left>', '<C-w><', opts)
-- keymap('n', ',s<right>', '<C-w>>', opts)
-- keymap('n', ',s<up>', '<C-w>+', opts)
-- keymap('n', ',s<down>', '<C-w>-', opts)
keymap("n", "<C-Up>", ":resize +2<CR>", opts)
keymap("n", "<C-Down>", ":resize -2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Navigate buffers
keymap("n", "<S-j>", ":bnext<CR>", opts)
keymap("n", "<S-k>", ":bprevious<CR>", opts)

-- Insert --
-- Press kj fast to enter
keymap("i", "kj", "<ESC>", opts)

keymap('n', '<leader>xc', '<Cmd>q<CR>', opts)
keymap('n', '<leader>xs', '<Cmd>w<CR>', opts)
keymap('n', '<leader>xm', ':', { silent = false })

-- Do not yank with x
keymap('n', 'x', '"_x', opts)

-- Toggle true/false
vim.keymap.set('n', '<leader>ta', '<Cmd>ToggleAlternate<CR>', opts)

-- Save with root permission (not working for now)
--vim.api.nvim_create_user_command('W', 'w !sudo tee > /dev/null %', {})

-- Delete a word backwards
keymap('n', '<C-d>', 'vb"_d', opts)

-- Select all
keymap('n', '<C-a>', 'gg<S-v>G', opts)

-- Increment/Decrement for Number
keymap('n', '+', '<C-a>', opts)
keymap('n', '-', '<C-x>', opts)

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down
keymap("v", "<A-j>", ":m .+1<CR>==", opts)
keymap("v", "<A-k>", ":m .-2<CR>==", opts)
keymap("v", "p", '"_dP', opts)

-- Visual Block --
-- Move text up and down
-- keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
-- keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

-- block replace
keymap("x", ",rb", ":s/", { silent = false })
keymap("v", ",rb", ":s/", { silent = false })
keymap("n", ",rb", ":%s/", { silent = false })

-- Terminal --
-- Better terminal navigation
keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)

-- Git Plugin "neogit"
keymap("n", "<leader>gg", "<Cmd>Neogit<CR>", { desc = "Open Neogit" })
