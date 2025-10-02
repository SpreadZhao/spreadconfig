return {
  cmd = { 'asm-lsp' },
  single_file_support = true,
  filetypes = { 'asm', 'vmasm' },
  -- root_dir = function(fname)
  --   return vim.fs.dirname(vim.fs.find({ '.asm-lsp.toml', '.git' }, { path = fname, upward = true })[1])
  -- end,
}
