return { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
        {
            '<leader>cb',
            function()
                require('conform').format { async = true, lsp_format = 'fallback' }
            end,
            mode = 'n',
            desc = '[C]onform [B]uffer',
        },
    },
    opts = {
        notify_on_error = false,
        format_on_save = nil,
        -- format_on_save = function(bufnr)
        --   -- Disable "format_on_save lsp_fallback" for languages that don't
        --   -- have a well standardized coding style. You can add additional
        --   -- languages here or re-enable it for the disabled ones.
        --   local disable_filetypes = { c = true, cpp = true }
        --   if disable_filetypes[vim.bo[bufnr].filetype] then
        --     return nil
        --   else
        --     return {
        --       timeout_ms = 500,
        --       lsp_format = 'fallback',
        --     }
        --   end
        -- end,
        formatters_by_ft = {
            bash = { 'shfmt' },
            javascript = { 'prettierd' },
            zsh = { 'shfmt' },
            sh = { 'shfmt' },
            c = { 'clang-format' },
            cmake = { 'cmake-format' },
            cpp = { 'clang-format' },
            css = { 'prettierd', stop_after_first = true },
            html = { 'xmlstarlet', stop_after_first = true },
            xml = { 'xmlstarlet' },
            rust = { 'rustfmt', lsp_format = 'fallback' },
            lua = { lsp_format = 'fallback' },
            json = { 'jq', lsp_format = 'fallback' },
        },
    },
}
