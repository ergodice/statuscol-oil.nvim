local M = {}

local util = require("statuscol-oil.util")
local bit = require("bit")

local function perm_to_string(mode)
    local function triad(val)
        return
            (bit.band(val, 4) ~= 0 and "r" or "-")
            .. (bit.band(val, 2) ~= 0 and "w" or "-")
            .. (bit.band(val, 1) ~= 0 and "x" or "-")
    end

    local perms = bit.band(mode, 0x1FF)

    return triad(bit.rshift(perms, 6))
        .. triad(bit.band(bit.rshift(perms, 3), 7))
        .. triad(bit.band(perms, 7))
end

M.permission = function(args)
    if not util.is_oil_buffer() or util.is_windows() then
        return ""
    end

    local ctx = util.get_context(args.buf, args.lnum)

    if ctx and ctx.stat and ctx.stat.mode then
        return "%#NonText#" .. perm_to_string(ctx.stat.mode)
    end

    return "%#NonText#---------"
end

return M
