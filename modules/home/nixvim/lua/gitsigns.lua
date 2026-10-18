return function(bufnr)
	local gitsigns = require("gitsigns")

	local function map(mode, l, r, opts)
		opts = opts or {}
		opts.buffer = bufnr
		vim.keymap.set(mode, l, r, opts)
	end

	local function nav_hunk(direction, preview)
		if vim.wo.diff then
			local key = direction == "next" and "]c" or "[c"
			vim.cmd.normal({ key, bang = true })
		else
			gitsigns.nav_hunk(direction, { preview = preview })
		end
	end

	-- Navigation
	map("n", "]c", function()
		nav_hunk("next", false)
	end, { desc = "Jump to next git [c]hange" })

	map("n", "[c", function()
		nav_hunk("prev", false)
	end, { desc = "Jump to previous git [c]hange" })

	map("n", "<leader>hj", function()
		nav_hunk("next", true)
	end, { desc = "Git hunk: next with preview" })

	map("n", "<leader>hk", function()
		nav_hunk("prev", true)
	end, { desc = "Git hunk: previous with preview" })

	-- Actions
	-- visual mode
	map("v", "<leader>hs", function()
		gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
	end, { desc = "Git hunk: stage selection" })
	map("v", "<leader>hr", function()
		gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
	end, { desc = "Git hunk: reset selection" })
	-- normal mode
	map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "Git hunk: stage" })
	map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "Git buffer: stage all hunks" })
	map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Git hunk: reset" })
	map("n", "<leader>hv", gitsigns.select_hunk, { desc = "Git hunk: select" })
	map("n", "<leader>hq", function()
		gitsigns.setqflist(0)
	end, { desc = "Git buffer: list hunks" })
	map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "Git hunk: preview" })
	map("n", "<leader>hb", gitsigns.blame_line, { desc = "Git line: blame" })
	map("n", "<leader>hd", gitsigns.diffthis, { desc = "Git diff: index" })
	map("n", "<leader>hD", function()
		gitsigns.diffthis("@")
	end, { desc = "Git diff: last commit" })
	-- Toggles
	map("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "Toggle git line blame" })
	map("n", "<leader>tw", gitsigns.toggle_word_diff, { desc = "Toggle git word diff" })
	map("n", "<leader>tD", gitsigns.preview_hunk_inline, { desc = "[T]oggle git show [D]eleted" })
	map("n", "<leader>ha", gitsigns.blame, { desc = "Git file: blame" })
end
