local utils = require("cmp_css_variables.utils")

local Source = {
	config = {
		files = {},
		filetypes = { "css", "vue" },
	},
	cache = {},
	filetypes = {} -- a set of filetypes
}

Source.new = function(overrides)
	local self = setmetatable({}, { __index = Source })
	self.config = vim.tbl_extend("force", Source.config, overrides or {})
	for _, item in ipairs(self.config.filetypes) do
		self.filetypes[item] = true
	end
	return self
end


function Source:is_available()
	if self.config.files then
		if self.filetypes["*"] ~= nil or self.filetypes[vim.bo.filetype] ~= nil then
			return true
		end
	end
	return false
end

function Source:get_debug_name()
	return "css_variables"
end

function Source:get_trigger_characters()
	return { "-" }
end

function Source:complete(_, callback)
	local bufnr = vim.api.nvim_get_current_buf()
	local items = {}

	if not self.cache[bufnr] then
		items = utils.get_css_variables(self.config.files)

		if type(items) ~= "table" then
			return callback()
		end
		self.cache[bufnr] = items
	else
		items = self.cache[bufnr]
	end

	callback({ items = items or {}, isIncomplete = false })
end

function Source:resolve(completion_item, callback)
	callback(completion_item)
end

function Source:execute(completion_item, callback)
	callback(completion_item)
end

return {
	setup = function(overrides)
		require("cmp").register_source("css_variables", Source.new(overrides))
	end
}
