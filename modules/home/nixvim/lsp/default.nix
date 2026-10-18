{ config, lib, ... }:
let
  projectServers = lib.filterAttrs (
    name: server: name != "*" && server.enable && !server.activate
  ) config.lsp.servers;
in
{
  imports = [
    ./attach.nix
    ./lua.nix
    ./cpp.nix
    ./nix.nix
    ./python.nix
    ./rust.nix
    ./shell.nix
    ./go.nix
    ./yaml.nix
  ];
  extraFiles."lua/spreadconfig/lsp/init.lua".source = ../lua/lsp/init.lua;
  extraConfigLua = ''
    require('spreadconfig.lsp').enable(${lib.nixvim.toLuaObject (builtins.attrNames projectServers)})
  '';
}
