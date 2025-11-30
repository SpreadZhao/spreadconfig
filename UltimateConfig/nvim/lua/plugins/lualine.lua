return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local colors = {
      red = '#ca1243',
      black = '#000000',
      white = '#f3f3f3',
      light_green = '#83a598',
      orange = '#fe8019',
      green = '#8ec07c',
    }

    local theme = {
      normal = {
        a = { fg = colors.white, bg = colors.black },
        b = { fg = colors.white, bg = colors.black },
        c = { fg = colors.black, bg = colors.black },
        z = { fg = colors.white, bg = colors.black },
      },
      insert = { a = { fg = colors.white, bg = colors.black } },
      visual = { a = { fg = colors.white, bg = colors.black } },
      replace = { a = { fg = colors.white, bg = colors.black } },
    }

    local function search_result()
      if vim.v.hlsearch == 0 then
        return ''
      end
      local last_search = vim.fn.getreg '/'
      if not last_search or last_search == '' then
        return ''
      end
      local searchcount = vim.fn.searchcount { maxcount = 9999 }
      return last_search .. '(' .. searchcount.current .. '/' .. searchcount.total .. ')'
    end

    local function fmt(str, left)
      if str == nil or str == '' then
        return str
      end

      if left then
        return '|' .. str
      else
        return str .. '|'
      end
    end

    local function modified()
      if vim.bo.modified then
        return '+'
      elseif vim.bo.modifiable == false or vim.bo.readonly == true then
        return '-'
      end
      return ''
    end

    require('lualine').setup {
      options = {
        theme = theme,
        component_separators = '',
        section_separators = '',
        disabled_filetypes = { 'oil', 'alpha', 'dashboard', 'NvimTree', 'Outline' },
      },
      sections = {
        lualine_a = {
          {
            'mode',
            fmt = function(str)
              return str:sub(1, 1)
            end,
            padding = 0,
          },
        },
        lualine_b = {
          {
            'branch',
            fmt = function(str)
              return fmt(str, true)
            end,
            padding = 0,
            icons_enabled = false,
            icon = nil,
            draw_empty = false,
          },
          {
            'diff',
            fmt = function(str)
              return fmt(str, true)
            end,
            padding = 0,
            draw_empty = false,
          },
          {
            'diagnostics',
            source = { 'nvim' },
            sections = { 'error' },
            diagnostics_color = { error = { bg = colors.red, fg = colors.black } },
            padding = 0,
          },
          {
            'diagnostics',
            source = { 'nvim' },
            sections = { 'warn' },
            diagnostics_color = { warn = { bg = colors.orange, fg = colors.black } },
            padding = 0,
            fmt = function(str)
              if str == nil or str == '' then
                return '|'
              end
              return str
            end,
          },
          {
            'filename',
            file_status = false,
            path = 0,
            padding = 0,
          },
          { modified, color = { bg = colors.red }, padding = 0 },
          {
            '%w',
            cond = function()
              return vim.wo.previewwindow
            end,
          },
          {
            '%r',
            cond = function()
              return vim.bo.readonly
            end,
          },
          {
            '%q',
            cond = function()
              return vim.bo.buftype == 'quickfix'
            end,
          },
        },
        lualine_c = {},
        lualine_x = {},
        lualine_y = {
          {
            search_result,
            padding = 0,
            fmt = function(str)
              return fmt(str, false)
            end,
          },
          {
            'filetype',
            padding = 0,
            fmt = function(str)
              return fmt(str, false)
            end,
          },
        },
        lualine_z = {
          {
            '%l:%c',
            padding = 0,
            fmt = function(str)
              return fmt(str, false)
            end,
          },
          {
            '%p%%/%L',
            padding = 0,
          },
        },
      },
      inactive_sections = {
        lualine_c = { '%f %y %m' },
        lualine_x = {},
      },
    }
  end,
}
