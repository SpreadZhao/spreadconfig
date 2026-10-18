return {
	direction_priority = function()
		local ctx = require("blink.cmp").get_context()
		local item = require("blink.cmp").get_selected_item()
		if ctx == nil or item == nil then
			return { "s", "n" }
		end

		local item_text = item.textEdit ~= nil and item.textEdit.newText or item.insertText or item.label
		local is_multi_line = item_text:find("\n") ~= nil

		-- Keep the upward direction until the menu reopens.
		if is_multi_line or vim.g.blink_cmp_upwards_ctx_id == ctx.id then
			vim.g.blink_cmp_upwards_ctx_id = ctx.id
			return { "n", "s" }
		end
		return { "s", "n" }
	end,
	columns = function()
		return {
			{ "label" },
			{ "kind_icon", "kind", gap = 1 },
			{ "source_name", gap = 1 },
		}
	end,
	kind_icon = function(ctx)
		local icon = ctx.kind_icon
		if vim.tbl_contains({ "Path" }, ctx.source_name) then
			local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
			if dev_icon then
				icon = dev_icon
			end
		else
			icon = require("lspkind").symbol_map[ctx.kind] or ""
		end

		return icon .. ctx.icon_gap
	end,
	kind_highlight = function(ctx)
		local hl = ctx.kind_hl
		if vim.tbl_contains({ "Path" }, ctx.source_name) then
			local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
			if dev_icon then
				hl = dev_hl
			end
		end
		return hl
	end,
	sources = function(ctx)
		local success, node = pcall(vim.treesitter.get_node)
		local common = { "buffer" }
		if success and node and vim.tbl_contains({ "comment", "line_comment", "block_comment" }, node:type()) then
			return common
		elseif vim.bo.filetype == "lua" then
			return vim.list_extend({ "lsp", "path" }, common)
		else
			return vim.list_extend({ "lsp", "path", "snippets" }, common)
		end
	end,
	buffer_bufnrs = function()
		return vim.tbl_filter(function(bufnr)
			return vim.bo[bufnr].buftype == ""
		end, vim.api.nvim_list_bufs())
	end,
	path_cwd = function(_)
		return vim.fn.getcwd()
	end,
}
