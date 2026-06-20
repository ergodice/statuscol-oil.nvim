local M = {}

local util = require("statuscol-oil.util")
local state = require("statuscol-oil.state")

local units = { "", "K", "M", "G", "T" }

local function get_digits_width(num)
    local digits = 1
    if num >= 1000 then
        digits = 3
    elseif num >= 10 then
        digits = 2
    end
    return digits
end

local function set_units(num, width)
    -- get units index
	local unit = 1

	while num >= 1000 and unit < #units do
		num = num / 1000
		unit = unit + 1
	end
    if unit == 1 then
        return (string.format("%.0f", num) .. units[unit])
    end

    -- get units in width
    local int_width = get_digits_width(num)
    local decimal_width = width - int_width - #"." - #units[unit]
    return (string.format("%." .. decimal_width .. "f", num) .. units[unit])
end

local function format_number(num, width, prefer_units)
	width = width or 5

    local united = set_units(num, width)
    local plain = tostring(math.floor(num))

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

M.format_num = format_number

M.size = function(args)
	if not util.is_oil_buffer() or args.empty then
		return ""
	end

	local ctx = util.get_context(args.buf, args.lnum)

	if ctx and ctx.stat and ctx.stat.size then
		return format_number(ctx.stat.size, state.opts.size_width, state.opts.size_prefer_units)
	end

	return string.rep("-", state.opts.size_width)
end

return M
