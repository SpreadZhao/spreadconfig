# Nixvim

`default.nix` is the Home Manager entry. Its `programs.nixvim.imports` imports
ordinary Nixvim modules; the children declare Nixvim options directly. Imports
are explicit, and the repository's Home Manager loader imports this directory
once. Do not add a sibling `modules/home/nixvim.nix`.

| Location | Owns |
| --- | --- |
| `core.nix` | Editor options, globals, basic autocommands and Nix indentation |
| `keymaps.nix` | General keymaps |
| `ui/` | VSCode palette, highlights, statusline and UI dependencies |
| `plugins/` | Completion, editing, Git, navigation, formatting and media |
| `lsp/` | Shared attachment behavior and one module per language |
| `lua/` | Longer callbacks, exposed through `extraFiles` and native `require` |

The module that uses a Lua file declares its `extraFiles` entry. Requiring a
callback does not invoke it: Gitsigns still runs its callback on buffer attach,
Lualine on `VimEnter`, completion on its existing insert/command-line events,
and the Markdown setup once for each Markdown buffer. Keep these timings when
moving more code out of Nix strings.

## Language servers

`lsp.servers` is the only server registry. Neovim matches filetypes, resolves
roots, and manages clients. This configuration does not inspect project flakes.

- C/C++ (`clangd`), Python (`basedpyright`), Go (`gopls`) and Rust
  (`rust_analyzer`) use the inherited project PATH. Enter `nix develop` before
  starting Neovim. Their modules use `package = null; activate = false;`; the
  shared startup gate reads their registered commands and enables them when
  available. Go also requires `go`, and Rust requires `cargo`. To disable a
  server entirely, set `enable = false`.
- Nix, Shell, Lua and YAML keep their editor-provided servers.
- C/C++ and Python use Neovim's native `root_markers` with the existing priority
  order. Do not reorder these markers as part of a structural change.
- Go executes only the `root_dir` callback from the Nixpkgs-locked
  `nvim-lspconfig/lsp/gopls.lua`. The source is evaluated per query to retain the
  previous cache scope. The plugin is not added to runtimepath, and its other
  defaults are not merged into our server configs.
- `lua/lsp/rust-root.lua` preserves the prior nvim-lspconfig-derived callback.
  The currently locked upstream callback also probes Rust sysroots, so adopting
  it requires a separate behavior change.
- Ordinary attachment keymaps use `lsp.keymaps`. Capability-dependent document
  highlights and inlay hints stay in `lua/lsp/attach.lua`.
