## Software I use (partial)

- Shell: Zsh with [Starship](https://starship.rs/)
- WM: [niri-wm/niri: A scrollable-tiling Wayland compositor.](https://github.com/niri-wm/niri)
- Terminal: [dnkl/foot: A fast, lightweight and minimalistic Wayland terminal emulator - Codeberg.org](https://codeberg.org/dnkl/foot)
- Launcher: [dnkl/fuzzel: App launcher and fuzzy finder for Wayland, inspired by rofi(1) and dmenu(1). - Codeberg.org](https://codeberg.org/dnkl/fuzzel)
- Notification: [dnkl/fnott: Keyboard driven and lightweight Wayland notification daemon for wlroots-based compositors. - Codeberg.org](https://codeberg.org/dnkl/fnott)
- Bar: [Alexays/Waybar: Highly customizable Wayland bar for Sway and Wlroots based compositors. :tada:](https://github.com/Alexays/Waybar)
- File Manager: [gokcehan/lf: Terminal file manager](https://github.com/gokcehan/lf) with these powerful addons:
    - [boydaihungst/org.freedesktop.FileManager1.common](https://github.com/boydaihungst/org.freedesktop.FileManager1.common)
    - [hunkyburrito/xdg-desktop-portal-termfilechooser: xdg-desktop-portal backend for choosing files with your favorite file chooser](https://github.com/hunkyburrito/xdg-desktop-portal-termfilechooser)
- Screenshot: 
    - [grim: Grab images from a Wayland compositor](https://sr.ht/~emersion/grim/)
    - [emersion/slurp: Select a region in a Wayland compositor](https://github.com/emersion/slurp)
    - [Jappie3/wayfreeze: Tool to freeze the screen of a Wayland compositor](https://github.com/Jappie3/wayfreeze)
- Screenrecord: 
    - [ammen99/wf-recorder](https://github.com/ammen99/wf-recorder)
    - [Open Broadcaster Software | OBS](https://obsproject.com/)
    - [emersion/slurp: Select a region in a Wayland compositor](https://github.com/emersion/slurp)
- Secrets:
    - [Pass: The Standard Unix Password Manager](https://www.passwordstore.org/)
    - [grimsteel/pass-secret-service: Implementation of org.freedesktop.secrets using `pass`](https://github.com/grimsteel/pass-secret-service)

> Some of them need more dependencies to be fully configured.

## Things to do after install

### files in `./secrets/`

- gh_token: github cli token `pass show github/token`
- passwd: login password `pass show sudo`
- qutebrowser_quickmarks: quickmarks of qutebrowser, can be an empty file

### make a soft link

[make a soft link](https://nixos-and-flakes.thiscute.world/zh/nixos-with-flakes/other-useful-tips#git-manage-nixos-config):

```bash
sudo ln -s /path/to/spreadconfig /etc/nixos
```

⚠️ However, I use path directly now. So make sure this repo is in:

```bash
~/workspaces/spreadconfig
```

### fcitx5

Now that I have not already make fcitx5 config to work, so stuff like theme,addons,classic-ui,etc. should be configured manually.

### wooz

wooz is not in 25.11 but in unstable, so I compile it and put it in ~/app/

follow [negrel/wooz: 🔍 A zoom / magnifier utility for wayland compositors.](https://github.com/negrel/wooz?tab=readme-ov-file#building-from-source) to compile.

### org.freedesktop.FileManager1.common

Functionality like "Show in folder" won't work unless you have a dbus service. Foturnately I found one: [boydaihungst/org.freedesktop.FileManager1.common](https://github.com/boydaihungst/org.freedesktop.FileManager1.common)

pull it, cd it, and add a c-cpp flake template:

```zsh
nix flake init --template "https://flakehub.com/f/the-nix-way/dev-templates/*#c-cpp"
```

modify `flake.nix`, change the packages into:

```nix
packages =
    with pkgs;
    [
        pkg-config
        dbus
        meson
        ninja
        pkgconf
        libcap
        gcc
        clang-tools
        pkgconf
        systemd
        glib
        cmake
    ]
    ++ (if stdenv.hostPlatform.system == "aarch64-darwin" then [ ] else [ gdb ]);
```

> There may be something useless like `cmake`, but I'm lazy...

then

```zsh
nix develop -c zsh
```

and you can compile it. but before that, you should disable the warning-as-error:

```zsh
meson setup --reconfigure build --buildtype=debugoptimized
ninja -C build
```

Then you will get `./build/file_manager_dbus`. Move it to `~/app/` like wooz.

## Color Scheme

- foot
- gdu
- fnott
- niri
- qutebrowser
- swaylock
- waybar
- starship
- fcitx5
- fuzzel
- btop
- mpv
- nixvim
- bat
- zsh-syntax-highlighting
