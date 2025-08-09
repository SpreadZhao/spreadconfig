return {
  'stevearc/oil.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' }, -- use if you prefer nvim-web-devicons
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
  lazy = false,
  keys = {
    {
      '<leader>fs',
      '<CMD>Oil<CR>',
      mode = 'n',
      desc = '[F]ile [S]ystem',
    },
    {
      '<leader>nt',
      '<CMD>tabnew<CR><CMD>Oil<CR>',
      mode = 'n',
      desc = '[N]ew [T]ab',
    },
  },
  opts = {
    colums = {
      'icon',
      'permissions',
      'size',
      'mtime',
    },
  },
}
