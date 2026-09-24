{
  modulesPath,
  pkgs,
  ...
}:

let
  # nixos-26.05 currently declares the removed
  # services.wivrn.defaultRuntime option without a default, which makes the
  # otherwise usable module throw while evaluating any system.  Keep the
  # pinned module in use, but drop only that stale compatibility declaration.
  # This can be removed once the nixpkgs module no longer contains it.
  wivrnModule = builtins.toFile "wivrn-module.nix" (
    builtins.replaceStrings
      [
        "  imports = [\n    (lib.mkRemovedOptionModule [ \"services\" \"wivrn\" \"defaultRuntime\" ] ''\n      WiVRn now manages the active runtime itself, so this option has been removed.\n    '')\n  ];"
      ]
      [ "" ]
      (builtins.readFile "${modulesPath}/services/video/wivrn.nix")
  );
in
{
  disabledModules = [ "services/video/wivrn.nix" ];
  imports = [ wivrnModule ];

  # WiVRn is the OpenXR runtime/streaming server.  WayVR is launched by
  # WiVRn when a headset connects, so it appears in the headset as the
  # desktop environment/overlay application.
  services.wivrn = {
    enable = true;
    autoStart = true;
    openFirewall = true;

    # Allow the server to use asynchronous reprojection.  The module creates
    # the narrowly-scoped CAP_SYS_NICE wrapper required for this.
    highPriority = true;

    # Steam games run inside pressure-vessel.  Importing the OpenXR runtime
    # makes WiVRn and its xrizer/OpenComposite compatibility layer visible to
    # those games.
    steam = {
      enable = true;
      importOXRRuntimes = true;
    };

    # Build WiVRn with NVENC support; the Quadro P2000 can provide hardware
    # H.264/H.265 encoding without using the CPU for every frame.
    package = pkgs.wivrn.override { cudaSupport = true; };

    config = {
      enable = true;
      json = {
        # The NixOS module converts the package in this list to its absolute
        # executable path in WiVRn's generated JSON configuration.
        application = [ pkgs.wayvr ];
      };
    };
  };

  # GPU render-node access is needed by WiVRn/WayVR.  `video` is already
  # present in the host user configuration; keep `render` explicit here.
  users.users.tetra.extraGroups = [ "render" ];
}
