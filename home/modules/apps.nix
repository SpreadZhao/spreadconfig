{ lib, pkgs, ... }:

{
    imports = [
        ./programs
    ];

    home.packages = with pkgs; [
        zsh-syntax-highlighting
        zsh-autosuggestions
        zsh-completions
        zsh-fzf-tab
        gcc
        gdb
        gnumake
        cmake
        ninja
        (lib.hiPrio clang)
        clang-tools
        lldb
        cargo
        rustc
        python3
        go
        jetbrains-toolbox
        jadx
        ghidra-bin
        bash-language-server
        gopls
        lua-language-server
        nixd
        rust-analyzer
        cmake-format
        nixfmt
        nixfmt-tree
        rustfmt
        shfmt
        stylua
        xmlstarlet
        imagemagick
        mpv
        (feh.overrideAttrs (old: {
            postInstall = (old.postInstall or "") + ''
                substituteInPlace $out/share/applications/feh.desktop \
                  --replace-fail "Exec=feh --start-at %u" \
                                 "Exec=feh --theme fit --start-at %u"
            '';
        }))
        satty
        wf-recorder
        chafa
        ffmpeg
        ffmpegthumbnailer
        grim
        slurp
        wayfreeze
        (scrcpy.overrideAttrs (old: {
            postInstall = (old.postInstall or "") + ''
                substituteInPlace $out/share/applications/scrcpy.desktop \
                  --replace-fail "-c scrcpy\"" \
                                 "-c 'scrcpy --render-driver=opengl'\""
                rm $out/share/applications/scrcpy-console.desktop
            '';
        }))
        zathura
        obsidian
        starship
        fastfetch
        onefetch
        tealdeer
        nix-tree
        nvd
        gdu
        bluetui
        eza
        bat
        duf
        dust
        diff-so-fancy
        xeyes
        qrencode
        rar
        unzip
        zip
        p7zip
        wechat
        (qq.overrideAttrs (old: {
            postInstall = (old.postInstall or "") + ''
                substituteInPlace $out/share/applications/qq.desktop \
                  --replace-fail "$out/bin/qq" "$out/bin/qq --ozone-platform-hint=auto --enable-wayland-ime --wayland-text-input-version=3"
            '';
        }))
        (
            (qutebrowser.overrideAttrs (old: {
                postInstall = (old.postInstall or "") + ''
                    substituteInPlace $out/share/applications/org.qutebrowser.qutebrowser.desktop \
                      --replace-fail "Exec=qutebrowser" "Exec=env QT_SCALE_FACTOR=1.5 qutebrowser"
                '';
            })).override
            {
                enableWideVine = true;
            }
        )
        niri
        xwayland-satellite
        waybar
        libnotify
        wl-clipboard
        pastel
        telegram-desktop
        pass
        wbg
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji
        nerd-fonts.symbols-only
        ibm-plex
        tesseract
        poppler-utils
        lf
        trash-cli
        rsync
        rclone
        lazygit
        wooz
        file-manager-dbus
        element-desktop
        claude-code-bin
    ];
}
