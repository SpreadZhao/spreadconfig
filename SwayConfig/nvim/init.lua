-- require configs
require 'config.basic'
require 'config.keymaps'
require 'config.lsp'

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require('lazy').setup {
  spec = {
    -- Theme
    require 'plugins.vscode',
    -- Git
    require 'plugins.gitsigns',
    require 'plugins.lazygit',
    -- File Manage
    require 'plugins.oil',
    -- Basic Functionalities
    require 'plugins.autopairs',
    require 'plugins.blink-cmp',
    require 'plugins.conform',
    require 'plugins.flash',
    require 'plugins.fzf-lua',
    require 'plugins.indent_line',
    require 'plugins.lualine',
    require 'plugins.nvim-treesitter',
    require 'plugins.todo-comments',
    require 'plugins.toggleterm',
    require 'plugins.which-key',
    -- LSP Plugins
    require 'plugins.lsp.lazydev',
    require 'plugins.lsp.fidget',
    -- Debugger
    require 'plugins.debug',

    -- Deprecated
    -- require 'plugins.lsp.mason',
    -- require 'plugins.catppuccin',
    -- require 'plugins.leap',
    -- require 'plugins.mini',
    -- require 'plugins.telescope',
    -- require 'plugins.lsp.init-lsp'
    -- require 'plugins.lsp.nvim-lspconfig',
    -- require 'plugins.neo-tree',
    -- require 'kickstart.plugins.lint',
  },
  install = {
    colorscheme = { 'vscode' },
  },
}
-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
