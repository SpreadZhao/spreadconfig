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
