local M = {}

local bit = require("bit")
local devicons = require("nvim-web-devicons")

local defaults = require("statuscol-oil.config")
local state = require("statuscol-oil.state")

function M.setup(opts)
	opts = opts or {}

	state.opts = vim.tbl_deep_extend("force", defaults, opts)
end

-- 権限ビットを文字列（rwxrwxrwx）に変換する関数
local function perm_to_string(mode)
	local function triad(val)
		local r = bit.band(val, 4) ~= 0 and "r" or "-"
		local w = bit.band(val, 2) ~= 0 and "w" or "-"
		local x = bit.band(val, 1) ~= 0 and "x" or "-"
		return r .. w .. x
	end

	local perms = bit.band(mode, 0x1FF)
	local owner = bit.rshift(perms, 6)
	local group = bit.rshift(perms, 3) % 8
	local other = perms % 8

	return triad(owner) .. triad(group) .. triad(other)
end

local is_oil_buffer = function()
	return vim.bo.filetype == "oil"
end

local is_windows = function()
	return vim.fn.has("win32") == 1
end

M.permission = {
	text = {
		function(args)
			if not is_oil_buffer() or is_windows() then
				return ""
			end
			local oil = require("oil")
			local entry = oil.get_entry_on_line(args.buf, args.lnum)

			if entry and entry.name then
				local dir = oil.get_current_dir(args.buf)
				if dir then
					local full_path = dir .. entry.name
					local uv = vim.uv or vim.loop
					local stat = uv.fs_stat(full_path)

					if stat and stat.mode then
						return "%#NonText#" .. perm_to_string(stat.mode)
					end
				end
			end
			return "%#NonText#---------"
		end,
	},
}

M.icon = {
	text = {
		function(args)
			if not is_oil_buffer() then
				return ""
			end
			local oil = require("oil")
			local entry = oil.get_entry_on_line(args.buf, args.lnum)

			if entry and entry.name then
				local icon, hl_group
				if entry.type == "directory" then
					icon = "󰉋"
					hl_group = "Directory"
				else
					local ext = vim.fn.fnamemodify(entry.name, ":e")
					icon, hl_group = devicons.get_icon(entry.name, ext, { default = true })
				end

				-- フォールバック用のハイライト
				hl_group = hl_group or "Normal"

				-- 「%#ハイライトグループ名#アイコン 」の形式で返す
				return "%#" .. hl_group .. "#" .. icon .. " "
			end
			return "%#" .. "NonText" .. "#" .. "*" .. " "
		end,
	},
}

local units = { "", "K", "M", "G", "T" }

local function set_units(num, width)
	width = width or 5

	local unit = 1
	while num >= 1000 and unit < #units do
		num = num / 1000
		unit = unit + 1
	end

	local suffix = units[unit]

	-- 小数点以下2桁→1桁→0桁の順で試す
	for decimals = 2, 0, -1 do
		local str = string.format("%." .. decimals .. "f%s", num, suffix)

		-- 不要な0削除
		str = str:gsub("(%..-)0+$", "%1")
		str = str:gsub("%.$", "")

		if #str <= width then
			return str
		end
	end

	-- 万一収まらない場合
	return string.format("%.0f%s", num, suffix)
end

local function right_align(str, width)
	return string.format("%" .. width .. "s", str)
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

	return right_align(result, width)
end

M.size = {
	text = {
		function(args)
			if not is_oil_buffer() then
				return ""
			end
			local oil = require("oil")
			local entry = oil.get_entry_on_line(args.buf, args.lnum)

			if entry and entry.name then
				local dir = oil.get_current_dir(args.buf)
				if dir then
					local full_path = dir .. entry.name
					local uv = vim.uv or vim.loop
					local stat = uv.fs_stat(full_path)

					if stat and stat.size then
						return format_number(stat.size, state.opts.size_width, state.opts.prefer_units)
					end
				end
			end
			return string.rep("-", state.opts.size_width)
		end,
	},
	hl = "NonText",
}

local function format_time(unix_time, format)
	return os.date(format or "%Y-%m-%d %H:%M:%S", unix_time)
end

M.mtime = {
	text = {
		function(args)
			if not is_oil_buffer() then
				return ""
			end
			local oil = require("oil")
			local entry = oil.get_entry_on_line(args.buf, args.lnum)

			if entry and entry.name then
				local dir = oil.get_current_dir(args.buf)
				if dir then
					local full_path = dir .. entry.name
					local uv = vim.uv or vim.loop
					local stat = uv.fs_stat(full_path)

					if stat and stat.mtime then
						return format_time(stat.mtime.sec, state.opts.mtime_format)
					end
				end
			end
			return "xxx"
		end,
	},
	hl = "NonText",
}

local username_from_uid

if not is_windows() then
	local uid_to_name = {}

	for line in io.lines("/etc/passwd") do
		local name, _, uid = line:match("^([^:]+):([^:]*):(%d+):")
		if name and uid then
			uid_to_name[tonumber(uid)] = name
		end
	end

	username_from_uid = function(uid)
		return uid_to_name[uid]
	end
end

M.owner = {
	text = {
		function(args)
			if not is_oil_buffer() or is_windows() then
				return ""
			end
			local oil = require("oil")
			local entry = oil.get_entry_on_line(args.buf, args.lnum)

			if entry and entry.name then
				local dir = oil.get_current_dir(args.buf)
				if dir then
					local full_path = dir .. entry.name
					local uv = vim.uv or vim.loop
					local stat = uv.fs_stat(full_path)

					if stat and stat.uid then
						return username_from_uid(stat.uid)
					end
				end
			end
			return "xxx"
		end,
	},
	hl = "NonText",
}

local groupname_from_gid

if not is_windows() then
	local gid_to_name = {}

	for line in io.lines("/etc/group") do
		local name, _, gid = line:match("^([^:]+):([^:]*):(%d+):")
		if name and gid then
			gid_to_name[tonumber(gid)] = name
		end
	end

	groupname_from_gid = function(gid)
		return gid_to_name[gid]
	end
end

M.group = {
	text = {
		function(args)
			if not is_oil_buffer() or is_windows() then
				return ""
			end
			local oil = require("oil")
			local entry = oil.get_entry_on_line(args.buf, args.lnum)

			if entry and entry.name then
				local dir = oil.get_current_dir(args.buf)
				if dir then
					local full_path = dir .. entry.name
					local uv = vim.uv or vim.loop
					local stat = uv.fs_stat(full_path)

					if stat and stat.gid then
						return groupname_from_gid(stat.gid)
					end
				end
			end
			return "xxx"
		end,
	},
	hl = "NonText",
}

M.whitespace = {
	text = { " " },
	condition = {
		function()
			return is_oil_buffer()
		end,
	},
}

return M
