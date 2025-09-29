return {
  'ibhagwan/fzf-lua',
  -- optional for icon support
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  -- or if using mini.icons/mini.nvim
  -- dependencies = { "echasnovski/mini.icons" },
  keys = {
    {
      '<leader>ff',
      function()
        require('fzf-lua').files()
      end,
      mode = 'n',
      desc = '[F]ind [F]iles',
    },
    {
      '<leader>ge',
      function()
        require('fzf-lua').buffers()
      end,
      mode = 'n',
      desc = 'Find Buffers',
    },
    {
      '<leader>fh',
      function()
        require('fzf-lua').oldfiles()
      end,
      mode = 'n',
      desc = '[F]ind [H]istory',
    },
    {
      '<leader>ft',
      function()
        require('fzf-lua').tabs()
      end,
      mode = 'n',
      desc = '[F]ind [T]ab',
    },
    {
      '<leader>fk',
      function()
        require('fzf-lua').keymaps()
      end,
      mode = 'n',
      desc = '[F]ind [K]eymaps',
    },
    {
      '<leader>fe',
      function()
        require('fzf-lua').live_grep()
      end,
      mode = 'n',
      desc = '[F]ind [E]verything',
    },
    {
      '<leader>?',
      function()
        require('fzf-lua').helptags()
      end,
      mode = 'n',
      desc = '[F]ind Helps',
    },
    {
      '<leader>fgs',
      function()
        require('fzf-lua').git_status()
      end,
      mode = 'n',
      desc = '[F]ind [G]it [S]tatus',
    },
  },
}
