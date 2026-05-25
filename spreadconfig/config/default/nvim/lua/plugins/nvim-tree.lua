return {
  'nvim-tree/nvim-tree.lua',
  version = '*',
  lazy = false,
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  keys = {
    {
      '<leader>fs',
      '<CMD>Nvim<CR>',
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
  config = function()
    require('nvim-tree').setup {}
  end,
}
