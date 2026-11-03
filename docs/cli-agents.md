# CLI agents

The `llm-agents` input (`numtide/llm-agents.nix`) supplies the agent packages.
Its nixpkgs revision stays independent of the system revision so packages match
the Numtide binary cache configured in `modules/nixos/nix.nix`. Home Manager
installs these commands:

| Command | Account data |
| --- | --- |
| `codex-spreadzhao` | `~/.local/share/codex/profiles/spreadzhao` |
| `codex-supazodiac` | `~/.local/share/codex/profiles/supazodiac` |
| `agy` | `~/.gemini/antigravity-cli` and shared Gemini authentication |
| `claude` | Claude Code's standard paths and SOPS-managed settings |

The Codex profile paths follow `XDG_DATA_HOME` when set.
`modules/home/codex/profiles.nix` builds both launchers and their bash, fish
and zsh completions around the shared Codex binary. Each profile isolates its
login, conversations, SQLite state, skills and plugins while keeping the
session's XDG paths for external tools.

`modules/home/codex/default.nix` seeds each profile's `$CODEX_HOME/config.toml`
from `modules/home/codex/files/config.toml` on activation.

`modules/home/antigravity/default.nix` seeds
`~/.gemini/antigravity-cli/settings.json` from
`modules/home/antigravity/files/settings.json` and links
`~/.gemini/config/skills` to the global NAW skill bundle. Because Codex appends
project trust and runtime settings to `config.toml` and Antigravity rewrites
`settings.json` at runtime, activation writes each file only when it is missing
or a symlink, preserving existing regular files. Delete the target file and
activate again to re-seed it.

Codex's colored status line shows the model and reasoning level, current
directory, context usage, weekly limit, token usage and project name, in that
order.

## Notifications

Codex uses OSC 9 for desktop notifications regardless of terminal focus, with
tmux passthrough enabled across all windows and Foot notifications allowed
while focused. A completion alert previews the final response once Codex is
waiting for input. Approval requests, questions and plan prompts also trigger
alerts; progress messages do not. Foot's ordinary bell notifications are
disabled.

## Browser access

The shared Codex configuration runs the Nix-packaged `playwright-mcp` executable
with `--extension`, and `modules/nixos/chromium.nix` installs the Playwright MCP
Bridge extension through Chromium policy. After activation, restart Chromium and
check `chrome://extensions` for the extension. Start a Codex profile, check the
server with `/mcp`, then request a browser action. When prompted in Chromium,
approve the connection and choose a tab.

The extension uses the running browser's tabs and login sessions. See the
[Playwright extension instructions](https://github.com/microsoft/playwright/tree/main/packages/extension).
