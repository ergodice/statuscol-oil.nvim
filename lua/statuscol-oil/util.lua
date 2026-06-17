local M = {}

local oil = require("oil")

M.is_windows = vim.fn.has("win32") == 1

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
local dir_cache = {}

function M.get_context(buf, lnum)
	local entry = oil.get_entry_on_line(buf, lnum)
	if not entry then
		return nil
	end

    -- get key
    local dir = dir_cache[buf]
    if not dir then
        dir_cache[buf] = oil.get_current_dir(buf)
        dir = dir_cache[buf]
    end

    -- get/create ctx
    local ctx
    if cache[dir] then
        ctx = cache[dir][entry.name]
        if ctx then
            return ctx
        end
    else
        cache[dir] = {}
    end

	local path = dir and (dir .. entry.name) or nil

	local uv = vim.uv or vim.loop

	ctx = {
		entry = entry,
		path = path,
		stat = path and uv.fs_stat(path) or nil,
	}

	cache[dir][entry.name] = ctx

	return ctx
end

vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "OilActionsPost",
    callback = function(args)
        local dir = oil.get_current_dir(args.buf)
        print("clear cache   " ..dir)
        cache[dir] = {}
    end,
})

vim.api.nvim_create_autocmd("BufWipeout", {
    callback = function(args)
        dir_cache[args.buf] = nil
    end,
})

return M
