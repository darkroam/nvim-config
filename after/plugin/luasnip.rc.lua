local status, luasnip = pcall(require, "luasnip")
if not status then
	return
end

luasnip.config.set_config({
	history = true,
	updateevents = "TextChanged, TextChangedI",
	enable_autosnippets = true,
})
