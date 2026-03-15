{ lib, ... }:

{
    environment = {
        variables = {
            NIX_REMOTE = "daemon";
        };
        pathsToLink = [
            # https://nix-community.github.io/home-manager/options.xhtml#opt-xdg.portal.enable
            "/share/xdg-desktop-portal"
            "/share/applications"
        ];
        shellAliases = lib.mkForce { };
    };
}
