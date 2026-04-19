{ lib, pkgs, ... }:

{
  imports = [
    ./programs
  ];

  home.packages = with pkgs; [
    # Zsh plugins
    zsh-syntax-highlighting
    zsh-autosuggestions
    zsh-completions
    zsh-fzf-tab

    # Development tools - compilers & build tools
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

    # Coding
    jetbrains-toolbox
    jadx
    ghidra-bin
    claude-code

    # Language servers & formatters
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

    # Multimedia & screenshot tools
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

    # System information & disk utilities
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

    # Archive & compression
    xeyes
    qrencode
    rar
    unzip
    zip
    p7zip

    # Communication
    wechat
    (qq.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        substituteInPlace $out/share/applications/qq.desktop \
          --replace-fail "$out/bin/qq" "$out/bin/qq --ozone-platform-hint=auto --enable-wayland-ime --wayland-text-input-version=3"
      '';
    }))
    telegram-desktop
    element-desktop

    # Wayland utilities
    xwayland-satellite
    libnotify
    wl-clipboard
    pastel

    # Misc applications
    pass
    wbg
    wooz

    # Fonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    nerd-fonts.symbols-only
    maple-mono.NF-CN-unhinted
    ibm-plex

    # OCR & PDF
    tesseract
    poppler-utils

    # File & sync utilities
    trash-cli
    rsync
    rclone

    chromium

    hmcl
  ];
}
