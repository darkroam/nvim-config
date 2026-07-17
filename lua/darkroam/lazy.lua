local lazy_commit = "306a05526ada86a7b30af95c5cc81ffba93fef97"
local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local compat = require("darkroam.compat")
local uv = vim.uv or vim.loop

local function run(command)
	local output = vim.fn.system(command)
	if vim.v.shell_error ~= 0 then
		error(table.concat(command, " ") .. " failed:\n" .. output)
	end
	return vim.trim(output)
end

if not uv.fs_stat(lazy_path) then
	run({
		"git",
		"clone",
		"--filter=blob:none",
		"--no-checkout",
		"https://github.com/folke/lazy.nvim.git",
		lazy_path,
	})
	run({ "git", "-C", lazy_path, "checkout", "--detach", lazy_commit })
else
	local installed_commit = run({ "git", "-C", lazy_path, "rev-parse", "HEAD" })
	if installed_commit ~= lazy_commit then
		run({ "git", "-C", lazy_path, "checkout", "--detach", lazy_commit })
	end
end

vim.opt.rtp:prepend(lazy_path)

local parser_runtime_paths = {}
local seen_parser_paths = {}
for _, parser_path in ipairs(vim.api.nvim_get_runtime_file("parser/lua.so", true)) do
	local runtime_path = vim.fn.fnamemodify(parser_path, ":h:h")
	if not vim.startswith(runtime_path, vim.fn.stdpath("data")) and not seen_parser_paths[runtime_path] then
		seen_parser_paths[runtime_path] = true
		table.insert(parser_runtime_paths, runtime_path)
	end
end

require("lazy").setup({
	spec = {
		{ import = "darkroam.plugins" },
	},
	defaults = {
		lazy = true,
		version = false,
	},
	lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json",
	local_spec = false,
	install = {
		colorscheme = { "neosolarized", "habamax" },
	},
	checker = {
		enabled = false,
	},
	rocks = {
		enabled = false,
	},
	change_detection = {
		notify = false,
	},
	ui = {
		border = "rounded",
	},
	performance = {
		reset_packpath = true,
		rtp = {
			paths = parser_runtime_paths,
		},
	},
})

if not compat.supports("treesitter") then
	vim.opt.rtp:remove(vim.fn.stdpath("data") .. "/site")
end
