local M = {}

local oil = require("oil")

M.is_windows = function()
	return vim.fn.has("win32") == 1
end

M.is_oil_buffer = function()
	return vim.bo.filetype == "oil"
end

M.right_align = function(str, width)
	return string.format("%" .. width .. "s", str)
end

M.left_align = function(str, width)
	return string.format("%" .. width * -1 .. "s", str)
end

M.ellipsis = function(str, max_width, ellipse_text)
	ellipse_text = ellipse_text or "..."
	if #str <= max_width then
		return str
	end

	if max_width <= #ellipse_text then
		return ellipse_text
	end

	return str:sub(1, max_width - #ellipse_text) .. ellipse_text
end

local cache = {}

function M.get_context(buf, lnum)
	local key = buf .. ":" .. lnum

	local ctx = cache[key]
	if ctx then
		return ctx
	end

	local entry = oil.get_entry_on_line(buf, lnum)
	if not entry then
		return nil
	end

	local dir = oil.get_current_dir(buf)
	local path = dir and (dir .. entry.name) or nil

	local uv = vim.uv or vim.loop

	ctx = {
		entry = entry,
		path = path,
		stat = path and uv.fs_stat(path) or nil,
	}

	cache[key] = ctx

	return ctx
end

function M.clear_context_cache()
	cache = {}
end

return M
