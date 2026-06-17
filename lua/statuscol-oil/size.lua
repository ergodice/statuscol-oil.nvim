local M = {}

local util = require("statuscol-oil.util")
local state = require("statuscol-oil.state")

local units = { "", "K", "M", "G", "T" }

local function set_units(num)
	local unit = 1

	while num >= 1000 and unit < #units do
		num = num / 1000
		unit = unit + 1
	end

	if num >= 100 then
		return string.format("%.0f%s", num, units[unit])
	elseif num >= 10 then
		return string.format("%.1f%s", num, units[unit])
	else
		return string.format("%.2f%s", num, units[unit])
	end
end

local function format_number(num, width, prefer_units)
	width = width or 5

	local plain = tostring(math.floor(num))
	local united = set_units(num, width)

	local result

	if prefer_units then
		result = united
	else
		if #plain <= width then
			result = plain
		else
			result = united
		end
	end

	return util.right_align(result, width)
end

M.size = function(args)
	if not util.is_oil_buffer() or args.empty then
		return ""
	end

	local ctx = util.get_context(args.buf, args.lnum)

	if ctx and ctx.stat and ctx.stat.size then
		return format_number(ctx.stat.size, state.opts.size_width, state.opts.prefer_units)
	end

	return string.rep("-", state.opts.size_width)
end

return M
