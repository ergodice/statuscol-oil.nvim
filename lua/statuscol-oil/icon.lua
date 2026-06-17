local M = {}

local util = require("statuscol-oil.util")
local devicons = require("nvim-web-devicons")

M.icon = function(args)
	if not util.is_oil_buffer() or args.empty then
		return ""
	end

	local ctx = util.get_context(args.buf, args.lnum)
	local entry = ctx and ctx.entry

	if not entry then
		return "%#NonText#* "
	end

	local icon, hl_group

	if entry.type == "directory" then
		icon = "󰉋"
		hl_group = "Directory"
	else
		icon, hl_group = devicons.get_icon(entry.name, vim.fn.fnamemodify(entry.name, ":e"), { default = true })
	end

	return "%#" .. (hl_group or "Normal") .. "#" .. icon .. " "
end

return M
