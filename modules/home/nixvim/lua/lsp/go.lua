return function(source)
	return function(bufnr, on_dir)
		if not require("spreadconfig.lsp").available("gopls") then
			return
		end
		-- Re-evaluate the upstream chunk on every query: the previous configuration
		-- also scoped GOROOT/GOMODCACHE state to one root query.
		return dofile(source).root_dir(bufnr, on_dir)
	end
end
