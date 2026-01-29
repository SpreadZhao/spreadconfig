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
    ];

    hardware = {
        bluetooth.enable = true;
    };

    nixpkgs = {
        config = {
            allowUnfree = true;
            rocmSupport = true;
        };
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

    boot = {
        loader = {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
        };
        extraModulePackages = with config.boot.kernelPackages; [
            v4l2loopback
        ];
        kernelModules = [ "v4l2loopback" ];
        # see:
        # https://wiki.archlinux.org/title/V4l2loopback#Loading_the_kernel_module
        # https://wiki.nixos.org/wiki/OBS_Studio#Using_the_Virtual_Camera
        extraModprobeConfig = ''
            options v4l2loopback devices=1 video_nr=1 card_label="OBS Camera" exclusive_caps=1
        '';
        tmp = {
            cleanOnBoot = false;
        };
    };

    networking = {
        hostName = "thinkbook";
        networkmanager.enable = true;
    };

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
                    command = "niri-session";
                    user = "spreadzhao";
                };
            };
        };
        xserver.desktopManager.runXdgAutostartIfNone = true;
    };
    users = {
        users.spreadzhao = {
            isNormalUser = true;
            extraGroups = [
                "wheel" # Enable ‘sudo’ for the user.
                # "ydotool"
            ];
            # packages = with pkgs; [
            #   tree
            # ];
            # shell = pkgs.zsh;
            initialPassword = "${lib.strings.trim (builtins.readFile ./secrets/passwd)}";
        };
        defaultUserShell = pkgs.zsh;
    };
    environment = {
        pathsToLink = [
            # https://nix-community.github.io/home-manager/options.xhtml#opt-xdg.portal.enable
            "/share/xdg-desktop-portal"
            "/share/applications"
        ];
        systemPackages = with pkgs; [
            wget
            brightnessctl
            efibootmgr
            exfatprogs
            jq
            lsof
            net-tools
            ripgrep
            ntfs3g
            glib
        ];
        shellAliases = lib.mkForce { };
    };
    programs = {
        dconf.enable = true;
        nano.enable = false;
        zsh.enable = true;
        vim = {
            enable = true;
            defaultEditor = true;
        };
        nh = {
            enable = true;
            clean.enable = true;
            flake = "/home/spreadzhao/workspaces/spreadconfig";
        };
        # ydotool.enable = true;
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
                # glew_1_10
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

    security = {
        polkit = {
            enable = true;
            # https://wiki.nixos.org/wiki/Polkit#No_password_for_wheel
            extraConfig = ''
                polkit.addRule(function(action, subject) {
                    if (subject.isInGroup("wheel"))
                        return polkit.Result.YES;
                });
            '';
        };
        pam.services = {
            # https://wiki.nixos.org/wiki/Secret_Service#Auto-decrypt_on_login
            # login.enableGnomeKeyring = true;
            # https://github.com/swaywm/sway/issues/2773#issuecomment-427570877
            # https://wiki.nixos.org/wiki/Swaylock#Home_Manager_-_Through_Sway
            swaylock = { };
        };
        sudo.wheelNeedsPassword = false;
    };

    fonts.fontconfig = {
        subpixel.rgba = "rgb";
        antialias = true;
        hinting.enable = true;
        useEmbeddedBitmaps = true;
        cache32Bit = true;
    };

    system.stateVersion = "25.11"; # Did you read the comment?

}
