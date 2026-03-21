{
  description = "file-manager-dbus";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        pname = "file-manager-dbus";
        version = "git";

        src = pkgs.fetchFromGitHub {
          owner = "boydaihungst";
          repo = "org.freedesktop.FileManager1.common";
          rev = "master";
          hash = "sha256-FCmNqz8JaP6XUaJOoWw5Lfls3ThdY+Yv2kRdk8XIRic=";
        };

        nativeBuildInputs = [
          pkgs.meson
          pkgs.ninja
          pkgs.pkg-config
        ];

        buildInputs = [
          pkgs.glib
          pkgs.dbus
          pkgs.systemd
          pkgs.libcap
        ];

        mesonFlags = [
          "-Dwerror=false"
        ];

        dontUseMesonConfigure = false;
      };
    };
}
