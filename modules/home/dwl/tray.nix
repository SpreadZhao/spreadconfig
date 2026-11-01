{
  inputs,
  pkgs,
  ...
}:

{
  imports = [ inputs.sni-watcher.homeManagerModules.default ];

  services.sni-watcher = {
    enable = true;
    package = inputs.sni-watcher.packages.${pkgs.stdenv.hostPlatform.system}.default;
    systemdTarget = "dwl-session.target";
  };

  home.packages = [
    pkgs.jq
    pkgs.systemd
  ];
}
