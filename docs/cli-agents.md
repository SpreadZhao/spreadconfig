# CLI agents

The `llm-agents` input (`numtide/llm-agents.nix`) supplies the agent packages.
Its nixpkgs revision stays independent of the system revision so packages match
the Numtide binary cache configured in `modules/nixos/nix.nix`. Home Manager
installs these commands:

| Command | Account data |
| --- | --- |
| `codex-spreadzhao` | `~/.local/share/codex/profiles/spreadzhao` |
| `codex-supazodiac` | `~/.local/share/codex/profiles/supazodiac` |
| `agy` | `~/.gemini/antigravity-cli` |
| `claude` | `~/.claude` and `~/.claude.json` |

The Codex profile paths follow `XDG_DATA_HOME` when set.
`modules/home/codex/profiles.nix` builds both launchers and their bash, fish
and zsh completions around the shared Codex binary. Each profile isolates its
login, conversations, SQLite state, skills and plugins while keeping the
session's XDG paths for external tools. `modules/home/codex/default.nix` seeds
each profile's `$CODEX_HOME/config.toml` from
`modules/home/codex/files/config.toml`.

`modules/home/antigravity/default.nix` wraps `agy` with `WSL_INTEROP=1` so OAuth
tokens are stored in `~/.gemini/antigravity-cli/antigravity-oauth-token` instead
of the D-Bus Secret Service keyring. It links `~/.gemini/config/skills` to the
global NAW skill bundle and seeds `~/.gemini/antigravity-cli/settings.json` from
`modules/home/antigravity/files/settings.json`.

`modules/home/claude-code.nix` seeds `~/.claude/settings.json` from the
SOPS-rendered [`claude-settings.json`](sops.md#claude-code) template, which sets
the Anthropic-compatible GLM endpoint, `glm-api-key` credential and request
flags.

Models and effort levels are selected at runtime, and the clients write those
choices, project trust and other mutable settings back to their configuration
files. Activation copies each template with mode `0600` only when the target is
missing or a symlink, preserving existing regular files. Delete the target file
and activate again to re-seed it.

Codex's colored status line shows the model and reasoning level, current
directory, context usage, weekly limit, token usage and project name, in that
order. Antigravity stacks a custom status line below its built-in bar showing
the current directory, context window usage, 5-hour and weekly remaining quota
for the active model group, and session token usage.

## Notifications

Codex uses OSC 9 for desktop notifications regardless of terminal focus, with
tmux passthrough enabled across all windows and Foot notifications allowed
while focused. A completion alert previews the final response once Codex is
waiting for input. Approval requests, questions and plan prompts also trigger
alerts; progress messages do not. Foot's ordinary bell notifications are
disabled.

## Browser access

The shared Codex configuration runs the Nix-packaged `playwright-mcp` executable
with `--extension`. Its MCP environment selects `chromium` from `PATH`, sets the
user data directory to `/home/spreadzhao/.config/chromium`, and disables isolated
mode. The explicit user data directory prevents the Nix launcher from enabling
isolation at startup.

`modules/nixos/chromium.nix` installs the Playwright MCP Bridge extension through
Chromium policy. After activation, restart Chromium and check
`chrome://extensions` for the extension. Start a Codex profile, check the server
with `/mcp`, then request a browser action. When prompted in Chromium, approve
the connection and choose a tab.

For an existing Codex profile, apply the `[mcp_servers.playwright]` and
`[mcp_servers.playwright.env]` settings from
`modules/home/codex/files/config.toml` to `$CODEX_HOME/config.toml`, then restart
Codex.

The extension uses the running browser's tabs and login sessions. See the
[Playwright extension instructions](https://github.com/microsoft/playwright/tree/main/packages/extension).
