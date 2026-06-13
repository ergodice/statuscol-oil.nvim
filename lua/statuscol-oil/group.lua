local M = {}

local util = require("statuscol-oil.util")

local groupname_from_gid

if not util.is_windows() then
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

M.group = function(args)
    if not util.is_oil_buffer() or util.is_windows() then
        return ""
    end

    local ctx = util.get_context(args.buf, args.lnum)

    if ctx and ctx.stat and ctx.stat.gid then
        return groupname_from_gid(ctx.stat.gid) or tostring(ctx.stat.gid)
    end

    return "xxx"
end

return M
