{ ... }:

{
  disabledModules = [ ../../modules/home/jetbrains ];

  imports = [
    ./home/dwl.nix
  ];
}
