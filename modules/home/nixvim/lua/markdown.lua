return function()
	local function decode_uri_path(path)
		return path:gsub("%%(%x%x)", function(hex)
			return string.char(tonumber(hex, 16))
		end)
	end

	local function open_markdown_link_under_cursor()
		local line = vim.api.nvim_get_current_line()
		local col = vim.api.nvim_win_get_cursor(0)[2] + 1

		for start_pos, whole_link, raw_target in line:gmatch("()(!?%[[^%]]*%]%(([^%)]+)%))") do
			local end_pos = start_pos + #whole_link - 1

			if col >= start_pos and col <= end_pos then
				local target = raw_target:match("^%s*<([^>]+)>") or raw_target:match("^%s*([^%s]+)")

				if not target or target == "" then
					break
				end

				local is_url = target:match("^%a[%w+.-]*://")

				if not is_url then
					target = decode_uri_path(target)

					if not target:match("^/") then
						local base = vim.fn.expand("%:p:h")
						target = vim.fn.fnamemodify(base .. "/" .. target, ":p")
					end
				end

				local opener
				if vim.fn.has("mac") == 1 then
					opener = "open"
				elseif vim.fn.has("win32") == 1 then
					opener = "explorer"
				else
					opener = "xdg-open"
				end

				vim.fn.jobstart({ opener, target }, { detach = true })
				return
			end
		end

		vim.cmd("normal! gx")
	end

	vim.keymap.set("n", "gx", open_markdown_link_under_cursor, {
		buffer = true,
		desc = "Open markdown link relative to current file",
	})
end
