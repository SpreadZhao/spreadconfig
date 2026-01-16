# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # ./fcitx5-rime.nix
  ];

  hardware = {
    bluetooth.enable = true;
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
    overlays = [
      (final: prev: {
        qq = prev.qq.overrideAttrs (old: {
          postInstall = (old.postInstall or "") + ''
            substituteInPlace $out/share/applications/qq.desktop \
              --replace-fail "$out/bin/qq" "$out/bin/qq --ozone-platform-hint=auto --enable-wayland-ime --wayland-text-input-version=3"
          '';
        });
      })
      (final: prev: {
        wechat = prev.wechat.overrideAttrs (old: {
          postFixup = (old.postFixup or "") + ''
            substituteInPlace $out/share/applications/wechat.desktop \
              --replace-fail \
              "Exec=wechat" \
              "Exec=env QT_IM_MODULE=fcitx XMODIFIERS=@im=fcitx QT_SCREEN_SCALE_FACTORS='eDP-1=2.0;HDMI-A-1=1.0;DP-2=1.0' wechat"
          '';
        });
      })
    ];
  };

  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      settings = {
        # Enable flakes and new 'nix' command
        experimental-features = "nix-command flakes";
        # Opinionated: disable global registry
        flake-registry = "";
        # Workaround for https://github.com/NixOS/nix/issues/9574
        nix-path = config.nix.nixPath;
        substituters = [
          "https://mirrors.ustc.edu.cn/nix-channels/store"
          "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
          "https://cache.nixos.org"
        ];
      };
      # Opinionated: disable channels
      channel.enable = false;

      # Opinionated: make flake registry and nix path match flake inputs
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "thinkbook"; # Define your hostname.
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Shanghai";

  # console.font = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";

  services = {
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
    libinput.enable = true;
    openssh = {
      enable = true;
      settings = {
        # PermitRootLogin = "no"
      };
    };
    gvfs.enable = true;
    greetd = {
      enable = true;
      settings = {
        terminal = {
          vt = 1;
        };
        default_session = {
          command = "${pkgs.greetd}/bin/agreety --cmd zsh";
          user = "greeter";
        };
        initial_session = {
          command = "/home/spreadzhao/scripts/niri/start_niri_greetd.sh";
          user = "spreadzhao";
        };
      };
    };
    xserver.desktopManager.runXdgAutostartIfNone = true;
  };

  users.users.spreadzhao = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
    # shell = pkgs.zsh;
    initialPassword = "1";
  };

  environment.systemPackages = with pkgs; [
    wget
    brightnessctl
    efibootmgr
    exfatprogs
    jq
    lsof
    net-tools
    ripgrep
    ntfs3g
    zsh-syntax-highlighting
    zsh-autosuggestions
    zsh-completions
    zsh-fzf-tab
    fzf
    eza
    bat
    fnm
    zoxide
    starship
    duf
    dust
    diff-so-fancy
    unrar
    rar
    unzip
    zip
    fastfetch
    onefetch
    btop
    # rocmPackages.rocm-smi
    tealdeer
    nix-tree
    gcc
    gdb
    gnumake
    cmake
    ninja
    clang
    clang-tools
    # rustup
    rustc
    cargo
    jdk21
    jdk17
    jdk11
    jdk8
    python3
    nixd
    nixfmt
    lua-language-server
    gdu
    bluetui
  ];
  environment.shellAliases = lib.mkForce { };
  users.defaultUserShell = pkgs.zsh;
  programs = {
    nano.enable = false;
    obs-studio = {
      enable = true;
      enableVirtualCamera = true;
      plugins = with pkgs.obs-studio-plugins; [
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    };
    niri = {
      enable = true;
      useNautilus = true;
    };
    foot = {
      enable = true;
      enableZshIntegration = false;
      enableFishIntegration = false;
      enableBashIntegration = false;
    };
    zsh = {
      enable = true;
    };
    lazygit = {
      enable = true;
      settings = {
        gui = {
          nerdFontsVersion = "3";
        };
        git = {
          pagers = [
            {
              pager = "diff-so-fancy";
            }
          ];
          autoFetch = false;
        };
      };
    };
    # https://github.com/NixOS/nixpkgs/issues/240444
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        SDL
        SDL2
        SDL2_image
        SDL2_mixer
        SDL2_ttf
        SDL_image
        SDL_mixer
        SDL_ttf
        alsa-lib
        at-spi2-atk
        at-spi2-core
        atk
        bzip2
        cairo
        cups
        curlWithGnuTls
        dbus
        dbus-glib
        desktop-file-utils
        e2fsprogs
        expat
        flac
        fontconfig
        freeglut
        freetype
        fribidi
        fuse
        fuse3
        gdk-pixbuf
        glew110
        glib
        gmp
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-ugly
        gst_all_1.gstreamer
        gtk2
        harfbuzz
        icu
        keyutils.lib
        libGL
        libGLU
        libappindicator-gtk2
        libcaca
        libcanberra
        libcap
        libclang.lib
        libdbusmenu
        libdrm
        libgcrypt
        libgpg-error
        libidn
        libjack2
        libjpeg
        libmikmod
        libogg
        libpng12
        libpulseaudio
        librsvg
        libsamplerate
        libthai
        libtheora
        libtiff
        libudev0-shim
        libusb1
        libuuid
        libvdpau
        libvorbis
        libvpx
        libxcrypt-legacy
        libxkbcommon
        libxml2
        mesa
        nspr
        nss
        openssl
        p11-kit
        pango
        pixman
        python3
        speex
        stdenv.cc.cc
        tbb
        udev
        vulkan-loader
        wayland
        xorg.libICE
        xorg.libSM
        xorg.libX11
        xorg.libXScrnSaver
        xorg.libXcomposite
        xorg.libXcursor
        xorg.libXdamage
        xorg.libXext
        xorg.libXfixes
        xorg.libXft
        xorg.libXi
        xorg.libXinerama
        xorg.libXmu
        xorg.libXrandr
        xorg.libXrender
        xorg.libXt
        xorg.libXtst
        xorg.libXxf86vm
        xorg.libpciaccess
        xorg.libxcb
        xorg.xcbutil
        xorg.xcbutilimage
        xorg.xcbutilkeysyms
        xorg.xcbutilrenderutil
        xorg.xcbutilwm
        xorg.xkeyboardconfig
        xz
        zlib
      ];
    };
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      nerd-fonts.symbols-only
    ];
    fontconfig = {
      defaultFonts = {
        emoji = [ "Noto Color Emoji" ];
        monospace = [
          "Noto Sans Mono"
          "Noto Sans Mono CJK SC"
          "Noto Sans Mono CJK HK"
          "Noto Sans Mono CJK TC"
          "Noto Sans Mono CJK JP"
          "Noto Sans Mono CJK KR"
          "Symbols Nerd Font Mono"
          "Noto Color Emoji"
        ];
        sansSerif = [
          "Noto Sans"
          "Noto Sans CJK SC"
          "Noto Sans CJK HK"
          "Noto Sans CJK TC"
          "Noto Sans CJK JP"
          "Noto Sans CJK KR"
          "Noto Color Emoji"
        ];
        serif = [
          "Noto Serif"
          "Noto Serif CJK SC"
          "Noto Serif CJK HK"
          "Noto Serif CJK TC"
          "Noto Serif CJK JP"
          "Noto Serif CJK KR"
          "Noto Color Emoji"
        ];
      };
    };
  };

  security.polkit = {
    enable = true;
  };

  system.stateVersion = "25.11"; # Did you read the comment?

}
