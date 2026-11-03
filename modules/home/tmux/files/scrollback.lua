package.preload["lualine"] = function()
	return {
		setup = function() end,
		hide = function() end,
		refresh = function() end,
	}
end

local pane_id = vim.env.TMUX_SCROLLBACK_PANE
local cx = tonumber(vim.env.TMUX_SCROLLBACK_CX) or 0
local cy = tonumber(vim.env.TMUX_SCROLLBACK_CY) or 0
local ph = tonumber(vim.env.TMUX_SCROLLBACK_PH) or vim.o.lines

vim.opt.laststatus = 0
vim.opt.cmdheight = 0
vim.opt.showtabline = 0
vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.signcolumn = "no"
vim.opt.foldcolumn = "0"
vim.opt.cursorline = false
vim.opt.list = false
vim.opt.scrolloff = 0
vim.opt.sidescrolloff = 0
vim.opt.wrap = false
vim.opt.fillchars:append({ eob = " " })
vim.opt.shortmess:append("I")

local buf = vim.api.nvim_get_current_buf()
vim.bo[buf].scrollback = 50000
vim.bo[buf].swapfile = false
vim.bo[buf].undofile = false
local chan = vim.api.nvim_open_term(buf, {})

local res = vim.system({ "tmux", "capture-pane", "-e", "-p", "-S", "-", "-t", pane_id }, { text = true }):wait()
local lines = vim.split((res.stdout or ""):gsub("\n$", ""), "\n", { plain = true })
local raw_total = #lines
local topline = math.max(1, raw_total - ph + 1)
local lnum = math.min(raw_total, topline + cy)

while #lines > lnum and lines[#lines] == "" do
	table.remove(lines)
end

local expected_lines = #lines
vim.api.nvim_chan_send(chan, table.concat(lines, "\r\n"))

vim.wait(500, function()
	return vim.api.nvim_buf_line_count(buf) >= expected_lines
end, 1)

vim.fn.winrestview({ topline = topline, lnum = lnum, col = 0 })
if cx > 0 then
	vim.cmd("normal! " .. (cx + 1) .. "|")
end

for _, key in ipairs({ "i", "I", "a", "A" }) do
	vim.keymap.set("n", key, "<Nop>", { buffer = buf, silent = true })
end
for key, dir in pairs({ ["<C-h>"] = "-L", ["<C-j>"] = "-D", ["<C-k>"] = "-U", ["<C-l>"] = "-R" }) do
	vim.keymap.set("n", key, function()
		vim.system({ "tmux", "select-pane", dir }):wait()
		vim.cmd("qa!")
	end, { buffer = buf, silent = true })
end
vim.keymap.set("n", "q", "<cmd>qa!<cr>", { buffer = buf, silent = true })
vim.keymap.set({ "n", "x", "o" }, "<leader>;", function()
	require("flash").jump()
end, { buffer = buf, silent = true, desc = "Jump Code" })
vim.api.nvim_create_autocmd("TermEnter", {
	buffer = buf,
	callback = function()
		vim.cmd.stopinsert()
	end,
})
vim.api.nvim_create_autocmd("TextYankPost", {
	buffer = buf,
	callback = function()
		local text = table.concat(vim.v.event.regcontents, "\n")
		if vim.v.event.regtype == "V" then
			text = text .. "\n"
		end
		vim.system({ "tmux", "set-buffer", "--", text })
	end,
})
