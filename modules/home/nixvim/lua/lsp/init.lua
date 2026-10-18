local M = {}

-- These tools are used by the respective upstream root callbacks.
local prerequisites = { gopls = { "go" }, rust_analyzer = { "cargo" } }

function M.available(name)
	local config = vim.lsp.config[name]
	local command = config and config.cmd
	if type(command) ~= "table" or vim.fn.executable(command[1]) ~= 1 then
		return false
	end
	for _, executable in ipairs(prerequisites[name] or {}) do
		if vim.fn.executable(executable) ~= 1 then
			return false
		end
	end
	return true
end

function M.enable(names)
	for _, name in ipairs(names) do
		if M.available(name) then
			vim.lsp.enable(name)
		end
	end
end

return M
