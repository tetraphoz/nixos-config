{ ... }:

{
  # XMonad remains the default Ly session; Hyprland is available as an
  # optional Wayland desktop for WiVRn and WayVR.
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
}
