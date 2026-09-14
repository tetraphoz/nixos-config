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

      # The P52's 06cb:009a reader is a Validity/Synaptics device that needs
      # the proprietary protocol implemented by python-validity.  Adding the
      # USB ID to libfprint's unrelated Synaptics driver does not make this
      # device work (and was the reason the previous attempt was ineffective).
      (final: prev: {
        # Also fix the DBus activation helper shipped by open-fprintd.  Its
        # upstream package fixes the systemd units but leaves this one /usr
        # path behind; the explicit NixOS unit normally masks that bug, while
        # this makes activation safe during boot as well.
        open-fprintd-p52 = prev.open-fprintd.overrideAttrs (old: {
          postInstall = (old.postInstall or "") + ''
            substituteInPlace $out/share/dbus-1/system-services/net.reactivated.Fprint.service \
              --replace-fail /usr/lib/open-fprintd $out/lib/open-fprintd
          '';
        });

        python-validity = final.python3Packages.buildPythonPackage rec {
          pname = "python-validity";
          version = "0.15";
          format = "setuptools";

          src = final.fetchFromGitHub {
            owner = "uunicorn";
            repo = "python-validity";
            rev = version;
            hash = "sha256-RflX7e6nd11pSg8mh3mjZiVGNUSdox/SKXHR4W+PhMs=";
          };

          nativeBuildInputs = with final; [
            gobject-introspection
            makeWrapper
            wrapGAppsNoGuiHook
          ];

          propagatedBuildInputs = with final.python3Packages; [
            cryptography
            dbus-python
            pygobject3
            pyusb
            pyyaml
          ];

          # The upstream package installs the DBus entry point as data rather
          # than as a Python console script.  Wrap it so its interpreter can
          # find both validitysensor and its Python dependencies on NixOS.
          postInstall = ''
            install -D -m 0644 etc/python-validity/dbus-service.yaml \
              $out/etc/python-validity/dbus-service.yaml
            install -D -m 0644 dbus_service/io.github.uunicorn.Fprint.conf \
              $out/share/dbus-1/system.d/io.github.uunicorn.Fprint.conf
            install -D -m 0644 debian/python3-validity.service \
              $out/lib/systemd/system/python3-validity.service
            install -D -m 0644 debian/python3-validity.udev \
              $out/lib/udev/rules.d/40-python3-validity.rules
            substituteInPlace $out/lib/udev/rules.d/40-python3-validity.rules \
              --replace-fail /bin/systemctl ${final.systemd}/bin/systemctl
            install -D -m 0644 LICENSE $out/share/licenses/python-validity/LICENSE
            install -D -m 0644 README.md $out/share/doc/python-validity/README.md
          '';

          dontWrapGApps = true;
          makeWrapperArgs = [ "\${gappsWrapperArgs[@]}" ];

          postFixup = ''
            wrapPythonProgramsIn "$out/lib/python-validity" "$out ''${pythonPath[*]}"
          '';

          meta = {
            description = "Validity fingerprint sensor DBus driver";
            homepage = "https://github.com/uunicorn/python-validity";
            license = final.lib.licenses.mit;
            platforms = final.lib.platforms.linux;
          };
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
