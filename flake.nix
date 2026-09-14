{
  description = "tetraphz";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pi.url = "github:lukasl-dev/pi.nix";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    pi,
    ...
  }:
  let
    system = "x86_64-linux";
    overlays = [
      pi.overlays.default

      # The P52's Synaptics Metallica reader (06cb:009a) is protocol
      # compatible with libfprint's Synaptics driver, but its product ID is
      # missing upstream. Keep this host-specific support in an overlay.
      (final: prev: {
        libfprint-p52 = prev.libfprint.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [ ./patches/synaptics-009a.patch ];

          # The upstream generated-hwdb test rejects locally added device IDs;
          # the normal build and udev checks remain enabled.
          doInstallCheck = false;
          mesonFlags = (old.mesonFlags or [ ]) ++ [
            "-Dintrospection=false"
            "-Dinstalled-tests=false"
          ];
        });

        fprintd-p52 = prev.fprintd.override {
          libfprint = final.libfprint-p52;
        };
      })
    ];
    pkgs = import nixpkgs {
      inherit system overlays;
      config.allowUnfree = true;
    };
  in
  {
    # Keep formatting available from the same pinned nixpkgs as the system.
    formatter.${system} = pkgs.nixfmt;

    nixosConfigurations.p52 =
      nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          ./hosts/p52/configuration.nix

          home-manager.nixosModules.home-manager

          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-backup";

            home-manager.users.tetra =
              import ./home/tetra.nix;
          }

          {
            nixpkgs.overlays = overlays;
          }
        ];
      };

    # Keep the standalone Home Manager command documented in README.org
    # working as well as the NixOS-integrated configuration above.
    homeConfigurations.tetra = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ ./home/tetra.nix ];
    };
  };
}
