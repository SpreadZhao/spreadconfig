{ ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      wayprompt =
        let
          version = "0.1.2-mzte.2";
          src = final.fetchFromGitea {
            domain = "git.mzte.de";
            owner = "LordMZTE";
            repo = "wayprompt";
            tag = "v${version}";
            hash = "sha256-uVkeLJgvdc6c7xmNUdWlUS1f3fx8cCIV/raw2prP4O4=";
          };
          deps = final.zig_0_16.fetchDeps {
            inherit version src;
            pname = "wayprompt";
            hash = "sha256-j1SrpUFgrtcv2pf43ZxRo3poYtMDQnWS3vmKkU5trE0=";
          };
        in
        prev.wayprompt.overrideAttrs {
          inherit version src;

          nativeBuildInputs = with final; [
            zig_0_16
            pkg-config
            wayland
            wayland-scanner
            scdoc
          ];

          zigBuildFlags = [ ];

          preBuild = ''
            ln -sf "${deps}" "$ZIG_GLOBAL_CACHE_DIR/p"
          '';
        };
    })
  ];
}
