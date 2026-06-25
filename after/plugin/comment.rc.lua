local status, comment = pcall(require, "Comment")
if not status then
	return
end

comment.setup({
	toggler = {
		line = ",ll",
	},
	opleader = {
		line = ",ll",
	},
	extra = {
		above = ",lO",
		eol = ",lA",
	},
})
