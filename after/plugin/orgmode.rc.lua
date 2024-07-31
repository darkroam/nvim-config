local status, orgmode = pcall(require, "orgmode")
if not status then
	return
end

orgmode.setup({
	orgmode_agenda_files = { "~/documents/org/*" },
	org_default_notes_file = "~/documents/org/refile.org",
})

local status2, org_bullets = pcall(require, "org-bullets")
if not status2 then
	return
end

org_bullets.setup({
	concealcursor = false, -- If false then when the cursor is on a line underlying characters are visible
	symbols = {
		-- headlines can be a list
		headlines = { "◉", "○", "✸", "✿" },
		checkboxes = {
			half = { "", "OrgTSCheckboxHalfChecked" },
			done = { "✓", "OrgDone" },
			todo = { "˟", "OrgTODO" },
		},
	},
})
