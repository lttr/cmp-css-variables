local M = {}
local cmp = require("cmp")

function M.split_path(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end

	local t = {}
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		table.insert(t, str)
	end
	return t
end

function M.join_paths(absolute, relative)
	local path = absolute
	for _, dir in ipairs(M.split_path(relative, "/")) do
		if dir == ".." then
			path = absolute:gsub("(.*)/.*", "%1")
		end
	end
	return path .. "/" .. relative:gsub("^[%./|%../]*", "")
end

function M.get_css_variables(files)
	local variables = {}
	local used = {}

	for _, file in ipairs(files) do
		local file_path = M.join_paths(vim.fn.getcwd(), file)
		if M.file_exists(file_path) then
			local content = vim.fn.readfile(file_path)

			-- Regex for matching CSS custom properties declarations:
			-- avoids matching variables that start with '_'
			-- -> I expect those are private
			-- avoids matching variables with default values set (contains ',')
			-- -> I expect those are usages, not declaration
			-- avoids matching anything after ';' or '}'
			-- -> I expect those characters mark end of declaration
			local regexp = "[-][-]([^_][^:,]*):([^;}]+);"

			for index, line in ipairs(content or {}) do
				for name, value in string.gmatch(line, regexp) do
					print(string.find(line, name))
					local lineBefore = content[index - 1]
					local comment = nil
					if lineBefore then
						comment = lineBefore:match("%s*/[*](.*)[*]/")
					end
					local file_name_from_file_path = file:match("([^/]+)$")
					local docs = value .. "\n\n" .. (comment and comment .. "\n\n" or "") .. file_name_from_file_path
					table.insert(variables, {
						label = "--" .. name,
						insertText = "--" .. name,
						kind = cmp.lsp.CompletionItemKind.Variable,
						documentation = docs,
					})
				end
			end
		end
	end

	return variables
end

M.file_exists = function(name)
	local f = io.open(name, "r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

-- function M.find_files(path)
-- 	local Job, exists = pcall(require, "plenary.job")
-- 	if not exists then
-- 		vim.notify(
-- 			"[cmp-css-variables]: Plenary is required as a dependency.",
-- 			vim.log.levels.ERROR,
-- 			{ title = "cmp-css-variables" }
-- 		)
-- 		return
-- 	end
-- 	local stdout = Job:new({
-- 		command = "find",
-- 		args = { ".", "-type", "d", "-name", "node_modules", "-prune", "-o", "-name", path, "-print" },
-- 	}):sync()
-- 	return stdout
-- end

return M
