{
  description = "tetraphz";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  }:
  {
    nixosConfigurations.p52 =
      nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./hosts/p52/configuration.nix

          home-manager.nixosModules.home-manager

          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.tetra =
              import ./home/tetra.nix;
          }
        ];
      };
  };
}
