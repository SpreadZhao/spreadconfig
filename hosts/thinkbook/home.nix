{ ... }:

{
  disabledModules = [ ../../modules/home/jetbrains ];

  imports = [
    ./home/dwl.nix
    ./home/kanshi.nix
  ];
}
