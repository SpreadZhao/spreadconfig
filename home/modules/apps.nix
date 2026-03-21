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
        obsidian
        fastfetch
        onefetch
        tealdeer
        nix-tree
        nvd
        bluetui
        eza
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
        xwayland-satellite
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
        trash-cli
        rsync
        rclone
        wooz
        element-desktop
        claude-code-bin
    ];
}
