local expected_version = assert(vim.env.DARKROAM_EXPECT_VERSION, "DARKROAM_EXPECT_VERSION is required")
local version = vim.version()
local actual_version = ("%d.%d.%d"):format(version.major, version.minor, version.patch)
local profiles = {
	["0.10.4"] = {
		lsp = false,
		telescope = false,
		treesitter = false,
		mason = { "stylua", "clang-format" },
		parsers = {},
	},
	["0.11.3"] = {
		lsp = true,
		telescope = false,
		treesitter = false,
		mason = { "stylua", "clang-format", "lua-language-server", "clangd" },
		parsers = {},
	},
	["0.11.7"] = {
		lsp = true,
		telescope = true,
		treesitter = false,
		mason = { "stylua", "clang-format", "lua-language-server", "clangd" },
		parsers = {},
	},
	["0.12.3"] = {
		lsp = true,
		telescope = true,
		treesitter = true,
		mason = { "stylua", "clang-format", "lua-language-server", "clangd", "tree-sitter-cli" },
		parsers = { "lua", "c", "commonlisp" },
	},
}
local profile = profiles[actual_version]
local failures = {}

local function check(condition, label, detail)
	if condition then
		return
	end
	local message = label
	if detail ~= nil then
		message = message .. ": " .. tostring(detail)
	end
	table.insert(failures, message)
end

check(actual_version == expected_version, "binary-version", actual_version)
check(profile ~= nil, "supported-profile", actual_version)
profile = profile or { lsp = false, telescope = false, treesitter = false, mason = {}, parsers = {} }
local expected_shell = "zsh"
if vim.fn.has("win32") == 1 then
	expected_shell = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell"
end
check(vim.o.shell == expected_shell, "shell-platform", vim.o.shell)
if vim.fn.has("win32") == 1 then
	check(vim.o.shellcmdflag:find("-Command", 1, true) ~= nil, "shell-powershell-command", vim.o.shellcmdflag)
	check(vim.o.shellcmdflag:find("/s /c", 1, true) == nil, "shell-not-cmd", vim.o.shellcmdflag)
end

local lock_path = vim.fn.stdpath("config") .. "/lazy-lock.json"
local lock_ok, lock = pcall(function()
	return vim.json.decode(table.concat(vim.fn.readfile(lock_path), "\n"))
end)
check(lock_ok and type(lock) == "table", "lockfile-readable", lock_path)
if not lock_ok or type(lock) ~= "table" then
	lock = {}
end

local plugins_ok, lazy_config = pcall(require, "lazy.core.config")
check(plugins_ok, "lazy-config-loaded", lazy_config)
local plugins = plugins_ok and lazy_config.plugins or {}
local groups = {
	lsp = { "nvim-lspconfig", "mason-lspconfig.nvim" },
	telescope = { "telescope.nvim", "telescope-file-browser.nvim", "plenary.nvim" },
	treesitter = { "nvim-treesitter", "nvim-treesitter-textobjects" },
}
local disabled = {}
for feature, names in pairs(groups) do
	if not profile[feature] then
		for _, name in ipairs(names) do
			disabled[name] = true
		end
	end
end

local lock_count = 0
local expected_count = 0
for name in pairs(lock) do
	lock_count = lock_count + 1
	local expected_present = not disabled[name]
	if expected_present then
		expected_count = expected_count + 1
	end
	check((plugins[name] ~= nil) == expected_present, "plugin-spec:" .. name, tostring(plugins[name] ~= nil))
end

local plugin_count = 0
for name in pairs(plugins) do
	plugin_count = plugin_count + 1
	check(lock[name] ~= nil, "plugin-in-lock:" .. name)
end
check(plugin_count == expected_count, "plugin-count", plugin_count)

local lazy_root = vim.fn.stdpath("data") .. "/lazy"
local function on_runtimepath(name)
	local expected_path = vim.fs.normalize(lazy_root .. "/" .. name)
	for _, path in ipairs(vim.api.nvim_list_runtime_paths()) do
		if vim.fs.normalize(path) == expected_path then
			return true
		end
	end
	return false
end

for name in pairs(disabled) do
	check(not on_runtimepath(name), "runtimepath-absent:" .. name)
end

local function command_exists(name)
	return vim.fn.exists(":" .. name) == 2
end

local function mapping_exists(mode, lhs)
	local mapping = vim.fn.maparg(lhs, mode, false, true)
	return type(mapping) == "table" and next(mapping) ~= nil
end

local function plugin_loaded(name)
	local plugin = plugins[name]
	return plugin ~= nil and plugin._ ~= nil and plugin._.loaded ~= nil
end

local function same_list(actual, expected)
	return type(actual) == "table" and table.concat(actual, "\0") == table.concat(expected, "\0")
end

local function trigger(command, plugin_name, close_command)
	local ok, err = pcall(vim.cmd, command)
	check(ok, "trigger:" .. command, err)
	check(plugin_loaded(plugin_name), "plugin-loaded:" .. plugin_name)
	if ok and close_command then
		local close_ok, close_err = pcall(vim.cmd, close_command)
		check(close_ok, "close:" .. close_command, close_err)
	end
end

check(command_exists("LspInstall") == profile.lsp, "command-gate:LspInstall")
check(plugin_loaded("nvim-lspconfig") == profile.lsp, "startup-load:nvim-lspconfig")
if profile.lsp then
	local clangd = vim.lsp.config.clangd
	check(type(clangd) == "table", "clangd-config")
	if type(clangd) == "table" then
		check(type(clangd.before_init) == "function", "clangd-before-init")
		check(same_list(clangd.capabilities.offsetEncoding, { "utf-8", "utf-16" }), "clangd-upstream-offset")

		local params = { capabilities = vim.deepcopy(clangd.capabilities) }
		if type(clangd.before_init) == "function" then
			clangd.before_init(params, clangd)
		end
		check(
			params.capabilities.offsetEncoding == nil,
			"clangd-wire-offset",
			vim.inspect(params.capabilities.offsetEncoding)
		)
		check(
			same_list(params.capabilities.general.positionEncodings, { "utf-8", "utf-16", "utf-32" }),
			"clangd-wire-position-encodings",
			vim.inspect(params.capabilities.general.positionEncodings)
		)
		check(params.capabilities.textDocument.completion.editsNearCursor == true, "clangd-wire-edits-near-cursor")
	end
end

local original_buffer = vim.api.nvim_get_current_buf()
local options_buffer = vim.api.nvim_create_buf(false, true)
local options_ok, options_err = pcall(function()
	vim.api.nvim_set_current_buf(options_buffer)
	vim.cmd("setfiletype sh")
	local formatoptions = vim.bo.formatoptions
	for _, flag in ipairs({ "1", "c", "r", "o" }) do
		check(not formatoptions:find(flag, 1, true), "formatoptions-disabled:" .. flag, formatoptions)
	end
	for _, flag in ipairs({ "j", "l", "q" }) do
		check(formatoptions:find(flag, 1, true) ~= nil, "formatoptions-preserved:" .. flag, formatoptions)
	end
end)
vim.api.nvim_set_current_buf(original_buffer)
vim.api.nvim_buf_delete(options_buffer, { force = true })
check(options_ok, "formatoptions-buffer", options_err)

local bootstrap = require("darkroam.bootstrap")
local bootstrap_plan = bootstrap.plan()
check(command_exists("DarkroamBootstrap"), "command:DarkroamBootstrap")
check(not bootstrap.is_running(), "bootstrap-idle")
check(bootstrap.last_report() == nil, "bootstrap-no-startup-report")
check(bootstrap_plan.version == actual_version, "bootstrap-plan:version", bootstrap_plan.version)
check(bootstrap_plan.features.lsp == profile.lsp, "bootstrap-plan:lsp")
check(bootstrap_plan.features.treesitter == profile.treesitter, "bootstrap-plan:treesitter")
check(same_list(bootstrap_plan.mason, profile.mason), "bootstrap-plan:mason", vim.inspect(bootstrap_plan.mason))
check(same_list(bootstrap_plan.parsers, profile.parsers), "bootstrap-plan:parsers", vim.inspect(bootstrap_plan.parsers))
check(same_list(bootstrap_plan.external, {}), "bootstrap-plan:external", vim.inspect(bootstrap_plan.external))
check(plugin_loaded("mason.nvim") == profile.lsp, "bootstrap-no-startup-mason-load")

local telescope_keys = { ",rr", ",dd", ",bb", ";t", ";;", ";e", ",kk", ",xf" }
check(command_exists("Telescope") == profile.telescope, "command-gate:Telescope")
for _, lhs in ipairs(telescope_keys) do
	check(mapping_exists("n", lhs) == profile.telescope, "keymap-gate:n:" .. lhs)
end

local treesitter_commands = { "TSUpdate", "TSInstall", "DarkroamTSInstall" }
for _, name in ipairs(treesitter_commands) do
	check(command_exists(name) == profile.treesitter, "command-gate:" .. name)
end
for _, mapping in ipairs({ { "x", "af" }, { "o", "af" }, { "x", "if" }, { "o", "if" } }) do
	check(mapping_exists(mapping[1], mapping[2]) == profile.treesitter, "keymap-gate:" .. table.concat(mapping, ":"))
end
check(plugin_loaded("nvim-treesitter") == profile.treesitter, "startup-load:nvim-treesitter")

trigger("NvimTreeOpen", "nvim-tree.lua", "NvimTreeClose")
trigger("ToggleTerm", "toggleterm.nvim", "ToggleTerm")
check(command_exists("TermExec"), "command:TermExec")
for _, name in ipairs({ "_LAZYGIT_TOGGLE", "_NODE_TOGGLE", "_NCDU_TOGGLE", "_HTOP_TOGGLE", "_PYTHON_TOGGLE" }) do
	check(_G[name] == nil, "terminal-helper-absent:" .. name, type(_G[name]))
end
trigger("ZenMode", "zen-mode.nvim", "ZenMode")

if profile.telescope then
	local ok, err = pcall(vim.cmd, "Telescope find_files")
	check(ok, "trigger:Telescope find_files", err)
	check(plugin_loaded("telescope.nvim"), "plugin-loaded:telescope.nvim")
	check(plugin_loaded("telescope-file-browser.nvim"), "plugin-loaded:telescope-file-browser.nvim")
	pcall(vim.cmd, "stopinsert")
	pcall(vim.cmd, "close!")

	local browser_ok, browser_err = pcall(vim.cmd, "Telescope file_browser")
	check(browser_ok, "trigger:Telescope file_browser", browser_err)
	pcall(vim.cmd, "stopinsert")
	pcall(vim.cmd, "close!")
end

local function bootstrap_cancel_smoke()
	require("lazy").load({ plugins = { "mason.nvim" }, wait = true })
	local leave_autocmds = vim.api.nvim_get_autocmds({ event = "VimLeavePre" })
	assert(leave_autocmds[1] and leave_autocmds[1].group_name == "DarkroamBootstrap", "exit guard is not first")

	local original_registry = package.loaded["mason-registry"]
	local original_treesitter = package.loaded["nvim-treesitter"]
	local original_out_write = vim.api.nvim_out_write
	local install_callback
	local parser_started = false
	local summary_count = 0
	local missing_name = profile.mason[1]
	local fake_package = {}

	function fake_package:is_installing()
		return false
	end

	function fake_package:install(_, callback)
		install_callback = callback
		return {}
	end

	package.loaded["mason-registry"] = {
		is_installed = function(name)
			return name ~= missing_name
		end,
		refresh = function(callback)
			callback(true, {})
		end,
		get_package = function(name)
			assert(name == missing_name, name)
			return fake_package
		end,
	}
	package.loaded["nvim-treesitter"] = {
		get_installed = function()
			return {}
		end,
		install = function()
			parser_started = true
			error("parser stage started after cancellation")
		end,
	}
	vim.api.nvim_out_write = function(message)
		if message:find("DARKROAM_BOOTSTRAP", 1, true) then
			summary_count = summary_count + 1
		end
		original_out_write(message)
	end

	local ok, err = xpcall(function()
		assert(bootstrap.run(), "bootstrap did not start")
		assert(
			vim.wait(1000, function()
				return install_callback ~= nil
			end, 10),
			"fake package was not started"
		)
		assert(bootstrap.is_running(), "bootstrap stopped before exit")

		vim.api.nvim_exec_autocmds("VimLeavePre", { modeline = false })
		local report = assert(bootstrap.last_report(), "cancel report is missing")
		assert(report.status == "CANCELLED", vim.inspect(report))
		assert(report.cancel_reason == "vim-leave", vim.inspect(report))
		assert(not bootstrap.is_running(), "bootstrap remained active")
		assert(vim.deep_equal(report.mason.pending, { missing_name }), vim.inspect(report.mason.pending))
		assert(#report.mason.ok == #profile.mason - 1, vim.inspect(report.mason.ok))
		assert(#report.parsers.pending == #profile.parsers, vim.inspect(report.parsers.pending))
		assert(#report.errors == 0, vim.inspect(report.errors))

		install_callback(false, "terminated")
		vim.wait(50, function()
			return false
		end, 10)
		local after_callback = bootstrap.last_report()
		assert(after_callback.status == "CANCELLED", vim.inspect(after_callback))
		assert(#after_callback.errors == 0, vim.inspect(after_callback.errors))
		assert(not parser_started, "parser stage started after cancellation")
		assert(summary_count == 1, "summary count: " .. summary_count)
	end, debug.traceback)

	vim.api.nvim_out_write = original_out_write
	package.loaded["mason-registry"] = original_registry
	package.loaded["nvim-treesitter"] = original_treesitter
	assert(ok, err)
end

local cancel_ok, cancel_err = pcall(bootstrap_cancel_smoke)
check(cancel_ok, "bootstrap-cancel", cancel_err)

if #failures > 0 then
	vim.api.nvim_err_writeln(
		"DARKROAM_COMPAT_FAIL version=" .. actual_version .. "\n- " .. table.concat(failures, "\n- ")
	)
	vim.cmd("cquit 1")
	return
end

vim.api.nvim_out_write(
	("DARKROAM_COMPAT_OK version=%s plugins=%d/%d lsp=%s telescope=%s treesitter=%s\n"):format(
		actual_version,
		plugin_count,
		lock_count,
		tostring(profile.lsp),
		tostring(profile.telescope),
		tostring(profile.treesitter)
	)
)
