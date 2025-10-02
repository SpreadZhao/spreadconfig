return {
  cmd = { 'kotlin-ls', '--stdio' },
  single_file_support = true,
  filetypes = { 'kotlin' },
  root_markers = {
    'settings.gradle',
    'settings.gradle.kts',
    'build.gradle',
    'build.gradle.kts',
    'pom.xml',
    'workspace.json',
  },
}
