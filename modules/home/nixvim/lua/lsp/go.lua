return function(source)
	return function(bufnr, on_dir)
		if not require("spreadconfig.lsp").available("gopls") then
			return
		end
		-- Re-evaluate per query so GOROOT/GOMODCACHE state does not leak between roots.
		return dofile(source).root_dir(bufnr, on_dir)
	end
end
