local M = {}

local minimum = {
	lsp = { 0, 11, 3 },
	telescope = { 0, 11, 7 },
	treesitter = { 0, 12, 0 },
}

function M.at_least(major, minor, patch)
	local version = vim.version()
	patch = patch or 0

	if version.major ~= major then
		return version.major > major
	end
	if version.minor ~= minor then
		return version.minor > minor
	end
	return version.patch >= patch
end

function M.supports(feature)
	local required = assert(minimum[feature], "unknown compatibility feature: " .. tostring(feature))
	return M.at_least(required[1], required[2], required[3])
end

function M.minimum(feature)
	local required = assert(minimum[feature], "unknown compatibility feature: " .. tostring(feature))
	return { required[1], required[2], required[3] }
end

return M
