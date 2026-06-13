local M = {}

local util = require("statuscol-oil.util")
local defaults = require("statuscol-oil.config")
local state = require("statuscol-oil.state")

function M.setup(opts)
	opts = opts or {}
	state.opts = vim.tbl_deep_extend("force", defaults, opts)
end

M.permission = {
	text = {
		function(args)
			return require("statuscol-oil.permission").permission(args)
		end,
	},
	condition = {
		function()
			return util.is_oil_buffer()
		end,
	},
}

M.icon = {
	text = {
        function (args)
            return require("statuscol-oil.icon").icon(args)
        end
	},
	condition = {
		function()
			return util.is_oil_buffer()
		end,
	},
}

M.size = {
	text = {
        function (args)
            return require("statuscol-oil.size").size(args)
        end
	},
	hl = "NonText",
	condition = {
		function()
			return util.is_oil_buffer()
		end,
	},
}


M.mtime = {
	text = {
        function (args)
            return require("statuscol-oil.mtime").mtime(args)
        end
	},
	hl = "NonText",
	condition = {
		function()
			return util.is_oil_buffer()
		end,
	},
}

M.owner = {
	text = {
        function (args)
            return require("statuscol-oil.owner").owner(args)
        end
	},
	hl = "NonText",
	condition = {
		function()
			return util.is_oil_buffer()
		end,
	},
}


M.group = {
	text = {
        function (args)
            return require("gstatuscol-oil.roup").group(args)
        end
	},
	hl = "NonText",
	condition = {
		function()
			return util.is_oil_buffer()
		end,
	},
}

M.whitespace = {
	text = { " " },
	condition = {
		function()
			return util.is_oil_buffer()
		end,
	},
}

return M
