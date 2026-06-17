local M = {}

local util = require("statuscol-oil.util")
local state = require("statuscol-oil.state")

local username_from_uid

if not util.is_windows then
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

M.owner = function(args)
    if not util.is_oil_buffer() or util.is_windows or args.empty then
        return ""
    end

    local ctx = util.get_context(args.buf, args.lnum)

    if ctx and ctx.stat and ctx.stat.uid then
        return util.left_align(
            util.ellipsis(
                username_from_uid(ctx.stat.uid) or tostring(ctx.stat.uid),
                state.opts.owner_width
            ),
            state.opts.owner_width
        )
    end

    return "xxx"
end

return M
