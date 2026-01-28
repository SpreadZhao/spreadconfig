{
    description = "NixOS configuration";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
        home-manager = {
            url = "github:nix-community/home-manager/release-25.11";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nixvim = {
            url = "github:nix-community/nixvim/nixos-25.11";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        catppuccin = {
            url = "github:catppuccin/nix/release-25.11";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs =
        {
            nixpkgs,
            home-manager,
            ...
        }@inputs:
        let
        in
        {
            nixosConfigurations = {
                thinkbook = nixpkgs.lib.nixosSystem {
                    # system = "x86_64-linux";
                    specialArgs = { inherit inputs; };
                    modules = [
                        ./configuration.nix
                        home-manager.nixosModules.home-manager
                        {
                            home-manager.useGlobalPkgs = true;
                            home-manager.useUserPackages = true;
                            home-manager.extraSpecialArgs = { inherit inputs; };
                            home-manager.users.spreadzhao = {
                                imports = [
                                    ./home.nix
                                ];
                            };
                            # Optionally, use home-manager.extraSpecialArgs to pass
                            # arguments to home.nix
                        }
                    ];
                };
            };
        };
}
