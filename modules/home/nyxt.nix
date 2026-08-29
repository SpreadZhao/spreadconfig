{
  # hostConfigSource,
  # inputs,
  # pkgs,
  # ...
}:

let
  # personalPackages = inputs.personal-packages.packages.${pkgs.stdenv.hostPlatform.system};
  # nyxt4 = pkgs.symlinkJoin {
  #   name = "nyxt4-profile";
  #   paths = [ personalPackages.nyxt4 ];
  #   nativeBuildInputs = [ pkgs.makeWrapper ];
  #   postBuild = ''
  #     rm "$out/bin/nyxt"
  #     makeWrapper "${personalPackages.nyxt4}/bin/nyxt" "$out/bin/nyxt" \
  #       --run 'export XDG_DATA_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}/nyxt4"' \
  #       --run 'export XDG_CACHE_HOME="''${XDG_CACHE_HOME:-$HOME/.cache}/nyxt4"'
  #   '';
  #   inherit (personalPackages.nyxt4) meta;
  # };
in
{
  # home.packages = [ nyxt4 ];
  #
  # xdg.configFile."nyxt/config.lisp".source = hostConfigSource "nyxt/config.lisp";
}
