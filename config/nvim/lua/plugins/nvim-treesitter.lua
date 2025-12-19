return { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    lazy = false,
    config = function ()
        require('nvim-treesitter').setup {
            -- require('nvim-treesitter').install({
            --     'rust',
            --     'javascript',
            --     'zig'
            -- })
        }
    end
}
