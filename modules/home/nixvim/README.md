# Nixvim

`default.nix` imports the Nixvim modules explicitly. The Home Manager loader
imports this directory once; do not add a sibling `modules/home/nixvim.nix`.

| Path | Contents |
| --- | --- |
| `core.nix`, `keymaps.nix` | Editor options, autocommands and general bindings |
| `ui/` | Colors, highlights and statusline |
| `plugins/` | Completion, editing, Git, navigation, formatting and media |
| `lsp/` | Server configuration and shared attachment behavior |
| `lua/` | Callbacks installed through the owning module's `extraFiles` |

Keep callback timing when moving Lua code: Gitsigns runs on buffer attachment,
Lualine on `VimEnter`, completion on insert/command-line events, and Markdown
setup once per Markdown buffer.

## Language servers

`lsp.servers` is the server registry. Neovim matches filetypes, resolves roots
and manages clients; it does not load project devShells.

Enter the project's `nix develop` or direnv environment before starting Neovim.
C/C++ (`clangd`), Python (`basedpyright`), Go (`gopls`) and Rust (`rust_analyzer`)
use its PATH. The startup gate enables them only when their commands are
available; Go also requires `go`, and Rust requires `cargo`. Their modules set
`package = null; activate = false;`. Set `enable = false` to disable a server.
Nix, Shell, Lua and YAML servers remain bundled with the editor. Formatters also
use the inherited PATH.

C/C++ and Python use ordered `root_markers`. Go evaluates the locked
nvim-lspconfig `gopls.lua` root callback per query, without adding the plugin to
runtimepath or importing its other defaults. Rust uses `lua/lsp/rust-root.lua`;
it omits the upstream sysroot probing. Review root-detection changes separately.

Ordinary attachment bindings use `lsp.keymaps`. Capability-dependent document
highlights and inlay hints live in `lua/lsp/attach.lua`.
