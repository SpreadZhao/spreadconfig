# Independent applications and packaging

Third-party applications requiring personally maintained packaging belong to
[SpreadZhao/nix-packages](https://github.com/SpreadZhao/nix-packages). Applications
developed from scratch belong to independent repositories. spreadconfig consumes
their flake packages and modules and owns desktop and host-specific policy.

| Application | Repository | Integration here |
| --- | --- | --- |
| flake-input-watcher | [flake-input-watcher](https://github.com/SpreadZhao/flake-input-watcher) | Enabled service, checkout path, compatibility script |
| notification-history | [notification-history](https://github.com/SpreadZhao/notification-history) | fnott enable policy, configured popup and Neovim dependencies, shortcut |
| fzf-popup | [fzf-popup](https://github.com/SpreadZhao/fzf-popup) | Foot adapter, Niri floating rule, callers |

All three inputs follow the root nixpkgs. notification-history's fzf-popup input follows the root fzf-popup. Update the corresponding input to adopt a new version.
Local development can use `--override-input NAME path:/path/to/NAME` and
`--no-write-lock-file` to avoid persisting local paths.

## Terminal and window manager boundary

The standalone fzf-popup package depends on Bash, coreutils and fzf. It accepts
candidates on stdin, arbitrary fzf arguments after `--`, and returns original
selected rows and fzf's exit status. An external launcher receives argv, executes
it and waits for completion; `FZF_POPUP_TITLE` provides the title. Without a
launcher it uses the current terminal.

`modules/home/fzf-popup` wraps the external package with a default Foot launcher
using `footclient --client-environment -a lick-foot`. Niri's existing `lick-foot`
rule sets floating mode and dimensions. Override `FZF_POPUP_LAUNCHER` or use
`--launcher EXECUTABLE` to choose another adapter. Changing the default terminal
or window manager requires changing this integration, not the shared program.

```sh
printf '%s\n' first second | fzf-popup --title 'Choose' -- --prompt='Pick> '
```

The configured package is injected into notification-history through its Nix
`override { fzf-popup = ...; neovim = ...; }` interface, with Neovim coming from
`programs.nixvim.build.package`. Clipboard history and the Foot launcher
use the same installed program. Preview and action logic stays with each caller:
cliphist decoding and images here, notification database, viewing and copying in the
notification-history repository. `fm` and `fm --dmenu` retain their current roles.

Ordinary terminal popup helpers and other application migrations are outside
this extraction. Each independent repository keeps only the package build and the built-in
Bash syntax/ShellCheck checks. Custom functional tests and their Python
dependencies have been removed. spreadconfig retains the workspace skill-source
check and direct configuration evaluation.
