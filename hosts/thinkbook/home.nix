{ ... }:

{
  disabledModules = [ ../../modules/home/hmcl.nix ];

  imports = [
    ./home/dwl.nix
    ./home/kanshi.nix
  ];
}
