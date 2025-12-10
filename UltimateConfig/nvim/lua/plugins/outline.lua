return {
    'hedyhli/outline.nvim',
    config = function()
        -- Example mapping to toggle outline
        vim.keymap.set('n', '<leader>ot', '<cmd>Outline<CR>', { desc = 'Toggle Outline' })
        vim.keymap.set('n', '<leader>of', '<cmd>OutlineFocus<CR>', { desc = 'Focus Outline' })

        require('outline').setup {
            -- Your setup opts here (leave empty to use defaults)
        }
    end,
}
