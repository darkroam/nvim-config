local compat = require("darkroam.compat")
local languages = require("darkroam.languages")

local M = {}

local running = false
local leaving = false
local active_report
local last_report

local language_order = { "lua", "c", "elisp", "go" }
local language_specs = {
	lua = {
		mason = { "stylua" },
		lsp = { "lua-language-server" },
		parsers = { "lua" },
	},
	c = {
		mason = { "clang-format" },
		lsp = { "clangd" },
		parsers = { "c" },
	},
	elisp = {
		parsers = { "commonlisp" },
	},
	go = {
		lsp = { "gopls" },
		parsers = { "go", "gomod", "gosum", "gowork" },
		external = { "gofmt" },
	},
}
local mason_executables = {
	stylua = { "stylua" },
	["clang-format"] = { "clang-format" },
	["lua-language-server"] = { "lua-language-server" },
	clangd = { "clangd" },
	["tree-sitter-cli"] = { "tree-sitter" },
	gopls = { "gopls" },
}

local function append_unique(target, seen, values)
	for _, value in ipairs(values or {}) do
		if not seen[value] then
			seen[value] = true
			table.insert(target, value)
		end
	end
end

local function current_version()
	local version = vim.version()
	return ("%d.%d.%d"):format(version.major, version.minor, version.patch)
end

function M.plan()
	local plan = {
		version = current_version(),
		features = {
			lsp = compat.supports("lsp"),
			treesitter = compat.supports("treesitter"),
		},
		mason = {},
		parsers = {},
		external = {},
	}
	local seen = {
		mason = {},
		parsers = {},
		external = {},
	}

	for _, language in ipairs(language_order) do
		if languages.syntax[language] then
			local spec = language_specs[language]
			append_unique(plan.mason, seen.mason, spec.mason)
			append_unique(plan.external, seen.external, spec.external)
		end
	end
	if plan.features.lsp then
		for _, language in ipairs(language_order) do
			if languages.syntax[language] then
				local spec = language_specs[language]
				append_unique(plan.mason, seen.mason, spec.lsp)
			end
		end
	end
	if plan.features.treesitter then
		for _, language in ipairs(language_order) do
			if languages.syntax[language] then
				local spec = language_specs[language]
				append_unique(plan.parsers, seen.parsers, spec.parsers)
			end
		end
	end

	if #plan.parsers > 0 then
		append_unique(plan.mason, seen.mason, { "tree-sitter-cli" })
	end

	return plan
end

function M.is_running()
	return running
end

function M.last_report()
	if last_report == nil then
		return nil
	end
	return vim.deepcopy(last_report)
end

local function contains(values, expected)
	for _, value in ipairs(values) do
		if value == expected then
			return true
		end
	end
	return false
end

local function clean_error(value)
	local message = type(value) == "string" and value or vim.inspect(value)
	return message:gsub("%s+", " ")
end

local function add_error(report, stage, name, err)
	table.insert(report.errors, {
		stage = stage,
		name = name,
		message = clean_error(err),
	})
end

local function installed_parsers(treesitter)
	local ok, values = pcall(treesitter.get_installed, "parsers")
	if not ok then
		return {}, values
	end
	return values, nil
end

local function mason_ready(registry, name)
	if not registry.is_installed(name) then
		return false, {}
	end
	local missing = {}
	for _, executable in ipairs(mason_executables[name] or {}) do
		if vim.fn.executable(executable) ~= 1 then
			table.insert(missing, executable)
		end
	end
	return #missing == 0, missing
end

local function join_or_dash(values)
	return #values > 0 and table.concat(values, ",") or "-"
end

local function progress(planned, section)
	local completed = {}
	for _, key in ipairs({ "skipped", "installed" }) do
		for _, name in ipairs(section[key] or {}) do
			completed[name] = true
		end
	end

	local ok = {}
	local pending = {}
	for _, name in ipairs(planned) do
		table.insert(completed[name] and ok or pending, name)
	end
	return ok, pending
end

local function is_active(report)
	return running and not leaving and active_report == report and report.status == "RUNNING"
end

local function publish(report)
	if report._published then
		return
	end
	report._published = true
	if active_report == report then
		active_report = nil
		running = false
	end

	local snapshot = vim.deepcopy(report)
	snapshot._published = nil
	last_report = snapshot
	local mason_ok = report.mason.ok or {}
	local parser_ok = report.parsers.ok or {}
	local external_ok = report.external.ok or {}
	local mason_incomplete = report.mason.missing or report.mason.pending or {}
	local parser_incomplete = report.parsers.missing or report.parsers.pending or {}
	local external_incomplete = report.external.missing or report.external.pending or {}
	local summary = {
		"DARKROAM_BOOTSTRAP",
		"status=" .. report.status,
	}
	if report.cancel_reason then
		table.insert(summary, "reason=" .. report.cancel_reason)
	end
	vim.list_extend(summary, {
		"version=" .. report.plan.version,
		("mason=%d/%d"):format(#mason_ok, #report.plan.mason),
		("parsers=%d/%d"):format(#parser_ok, #report.plan.parsers),
		("external=%d/%d"):format(#external_ok, #report.plan.external),
		"missing_mason=" .. join_or_dash(mason_incomplete),
		"missing_parsers=" .. join_or_dash(parser_incomplete),
		"missing_external=" .. join_or_dash(external_incomplete),
		"errors=" .. #report.errors,
	})
	vim.api.nvim_out_write(table.concat(summary, " ") .. "\n")

	if report.status == "CANCELLED" then
		return
	end
	if #report.errors > 0 then
		local messages = {}
		for _, item in ipairs(report.errors) do
			table.insert(messages, ("%s/%s: %s"):format(item.stage, item.name, item.message))
		end
		vim.notify(table.concat(messages, "\n"), vim.log.levels.ERROR, { title = "Darkroam bootstrap" })
	elseif #mason_incomplete > 0 or #parser_incomplete > 0 then
		vim.notify(
			("托管项目验证失败：Mason=%s；parser=%s"):format(
				join_or_dash(mason_incomplete),
				join_or_dash(parser_incomplete)
			),
			vim.log.levels.ERROR,
			{ title = "Darkroam bootstrap" }
		)
	elseif #external_incomplete > 0 then
		vim.notify(
			"缺少外部命令：" .. table.concat(external_incomplete, ", "),
			vim.log.levels.WARN,
			{ title = "Darkroam bootstrap" }
		)
	end
end

local function finish(report, registry, treesitter)
	if not is_active(report) then
		return
	end
	report.mason.ok = {}
	report.mason.missing = {}
	report.mason.missing_executables = {}
	for _, name in ipairs(report.plan.mason) do
		local ready, missing_executables = false, {}
		if registry then
			ready, missing_executables = mason_ready(registry, name)
		end
		if ready then
			table.insert(report.mason.ok, name)
		else
			table.insert(report.mason.missing, name)
			if #missing_executables > 0 then
				report.mason.missing_executables[name] = missing_executables
			end
		end
	end

	report.parsers.ok = {}
	report.parsers.missing = {}
	report.parsers.load_errors = {}
	local parser_values = {}
	if #report.plan.parsers > 0 and treesitter then
		local parser_error
		parser_values, parser_error = installed_parsers(treesitter)
		if parser_error then
			add_error(report, "parser-verify", "all", parser_error)
		end
	end
	for _, name in ipairs(report.plan.parsers) do
		if contains(parser_values, name) then
			local call_ok, loaded, load_error = pcall(vim.treesitter.language.add, name)
			if call_ok and loaded then
				table.insert(report.parsers.ok, name)
			else
				table.insert(report.parsers.missing, name)
				report.parsers.load_errors[name] = clean_error(call_ok and load_error or loaded)
			end
		else
			table.insert(report.parsers.missing, name)
		end
	end

	report.external.ok = {}
	report.external.missing = {}
	for _, name in ipairs(report.plan.external) do
		if vim.fn.executable(name) == 1 then
			table.insert(report.external.ok, name)
		else
			table.insert(report.external.missing, name)
		end
	end

	if #report.errors > 0 or #report.mason.missing > 0 or #report.parsers.missing > 0 then
		report.status = "FAILED"
	elseif #report.external.missing > 0 then
		report.status = "PARTIAL"
	else
		report.status = "OK"
	end

	publish(report)
end

local function cancel_active(reason)
	local report = active_report
	if not running or report == nil or report.status ~= "RUNNING" then
		return false
	end
	report.status = "CANCELLED"
	report.cancel_reason = reason
	report.mason.ok, report.mason.pending = progress(report.plan.mason, report.mason)
	report.parsers.ok, report.parsers.pending = progress(report.plan.parsers, report.parsers)
	report.external.ok = {}
	report.external.pending = vim.deepcopy(report.plan.external)
	publish(report)
	return true
end

local function install_parsers(report, registry)
	if not is_active(report) then
		return
	end
	if #report.plan.parsers == 0 then
		finish(report, registry, nil)
		return
	end

	local ok, treesitter = pcall(require, "nvim-treesitter")
	if not ok then
		add_error(report, "parser-load", "nvim-treesitter", treesitter)
		finish(report, registry, nil)
		return
	end

	local installed, installed_error = installed_parsers(treesitter)
	if installed_error then
		add_error(report, "parser-check", "all", installed_error)
		finish(report, registry, treesitter)
		return
	end

	local missing = {}
	for _, name in ipairs(report.plan.parsers) do
		if contains(installed, name) then
			table.insert(report.parsers.skipped, name)
		else
			table.insert(missing, name)
		end
	end
	if #missing == 0 then
		finish(report, registry, treesitter)
		return
	end

	local task_ok, task = pcall(treesitter.install, missing, { summary = true })
	if not task_ok then
		add_error(report, "parser-install", table.concat(missing, ","), task)
		finish(report, registry, treesitter)
		return
	end
	vim.notify("正在安装 parser：" .. table.concat(missing, ", "), vim.log.levels.INFO, {
		title = "Darkroam bootstrap",
	})
	if type(task) ~= "table" or type(task.await) ~= "function" then
		add_error(report, "parser-install", table.concat(missing, ","), "installer did not return an async task")
		finish(report, registry, treesitter)
		return
	end
	local await_ok, await_error = pcall(task.await, task, function(err, success)
		vim.schedule(function()
			if not is_active(report) then
				return
			end
			if err or success ~= true then
				add_error(report, "parser-install", table.concat(missing, ","), err or "installer returned false")
			else
				vim.list_extend(report.parsers.installed, missing)
			end
			finish(report, registry, treesitter)
		end)
	end)
	if not await_ok then
		add_error(report, "parser-install", table.concat(missing, ","), await_error)
		finish(report, registry, treesitter)
	end
end

local function install_mason_packages(report, registry, missing)
	if not is_active(report) then
		return
	end
	local remaining = #missing
	local function complete_one()
		if not is_active(report) then
			return
		end
		remaining = remaining - 1
		if remaining == 0 then
			install_parsers(report, registry)
		end
	end

	for _, name in ipairs(missing) do
		local package_name = name
		local package_ok, package = pcall(registry.get_package, package_name)
		if not package_ok then
			add_error(report, "mason-package", package_name, package)
			complete_one()
		elseif package:is_installing() then
			add_error(report, "mason-install", package_name, "package is already installing")
			complete_one()
		else
			local start_ok, start_error = pcall(function()
				package:install({}, function(success, err)
					vim.schedule(function()
						if not is_active(report) then
							return
						end
						local ready, missing_executables = mason_ready(registry, package_name)
						if success and ready then
							table.insert(report.mason.installed, package_name)
						else
							local verification_error = #missing_executables > 0
									and ("missing executable(s): " .. table.concat(missing_executables, ","))
								or "verification failed"
							add_error(report, "mason-install", package_name, err or verification_error)
						end
						complete_one()
					end)
				end)
			end)
			if not start_ok then
				add_error(report, "mason-install", package_name, start_error)
				complete_one()
			end
		end
	end
end

local function start_mason(report)
	if not is_active(report) then
		return
	end
	if #report.plan.mason == 0 then
		install_parsers(report, nil)
		return
	end

	local lazy_ok, lazy_error = pcall(function()
		require("lazy").load({ plugins = { "mason.nvim" }, wait = true })
	end)
	if not lazy_ok then
		add_error(report, "mason-load", "mason.nvim", lazy_error)
		finish(report, nil, nil)
		return
	end

	local registry_ok, registry = pcall(require, "mason-registry")
	if not registry_ok then
		add_error(report, "mason-load", "mason-registry", registry)
		finish(report, nil, nil)
		return
	end

	local missing = {}
	for _, name in ipairs(report.plan.mason) do
		if registry.is_installed(name) then
			table.insert(report.mason.skipped, name)
		else
			table.insert(missing, name)
		end
	end
	if #missing == 0 then
		install_parsers(report, registry)
		return
	end

	vim.notify("正在刷新 Mason registry", vim.log.levels.INFO, { title = "Darkroam bootstrap" })
	local refresh_ok, refresh_error = pcall(registry.refresh, function(success, result)
		vim.schedule(function()
			if not is_active(report) then
				return
			end
			if not success then
				add_error(report, "mason-refresh", "registry", result)
				finish(report, registry, nil)
				return
			end
			vim.notify("正在安装 Mason 项目：" .. table.concat(missing, ", "), vim.log.levels.INFO, {
				title = "Darkroam bootstrap",
			})
			install_mason_packages(report, registry, missing)
		end)
	end)
	if not refresh_ok then
		add_error(report, "mason-refresh", "registry", refresh_error)
		finish(report, registry, nil)
	end
end

function M.run()
	if leaving then
		vim.notify("Neovim 正在退出", vim.log.levels.WARN, { title = "Darkroam bootstrap" })
		return false
	end
	if running then
		vim.notify("bootstrap 已在运行", vim.log.levels.WARN, { title = "Darkroam bootstrap" })
		return false
	end

	local plan_ok, plan = pcall(M.plan)
	if not plan_ok then
		vim.notify(clean_error(plan), vim.log.levels.ERROR, { title = "Darkroam bootstrap plan" })
		return false
	end
	running = true
	local report = {
		status = "RUNNING",
		plan = plan,
		mason = { installed = {}, skipped = {} },
		parsers = { installed = {}, skipped = {} },
		external = {},
		errors = {},
	}
	active_report = report
	last_report = vim.deepcopy(report)
	vim.notify("正在检查语言工具链", vim.log.levels.INFO, { title = "Darkroam bootstrap" })
	start_mason(report)
	return true
end

function M.setup()
	local group = vim.api.nvim_create_augroup("DarkroamBootstrap", { clear = true })
	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = group,
		once = true,
		desc = "Cancel active Darkroam bootstrap before provider termination",
		callback = function()
			leaving = true
			cancel_active("vim-leave")
		end,
	})
	if vim.fn.exists(":DarkroamBootstrap") == 2 then
		return
	end
	vim.api.nvim_create_user_command("DarkroamBootstrap", M.run, {
		desc = "Install and verify tools selected by darkroam.languages",
	})
end

return M
