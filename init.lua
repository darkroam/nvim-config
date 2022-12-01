require("darkroam.options")
require("darkroam.keymaps")
require("darkroam.plugins")
require("darkroam.colorscheme")
require("darkroam.impatient")

local has = vim.fn.has
local is_mac = has("macunix")
local is_win = has("win32")

if is_mac then
	require("darkroam.macos")
end
if is_win then
	require("darkroam.windows")
end
