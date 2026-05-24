{
  inputs,
  ...
}:

{
  imports = [
    inputs.nixvim.homeModules.nixvim
    ../../home/modules
  ];
}
