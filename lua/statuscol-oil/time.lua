local M = {}

local util = require("statuscol-oil.util")
local state = require("statuscol-oil.state")

local time_cache = {}

local function format_time(unix_time, format)
	local key = unix_time .. "|" .. format

	local result = time_cache[key]
	if result then
		return result
	end

	result = os.date(format, unix_time)
	time_cache[key] = result

	return result
end

M.mtime = function(args)
	if not util.is_oil_buffer() then
		return ""
	end

	local ctx = util.get_context(args.buf, args.lnum)

	if ctx and ctx.stat and ctx.stat.mtime then
		return format_time(ctx.stat.mtime.sec, state.opts.mtime_format)
	end

	return "xxx"
end

return M
