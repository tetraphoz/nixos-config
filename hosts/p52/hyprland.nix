{ ... }:

{
  # Keep XMonad as the default Ly session; Hyprland is an optional Wayland
  # session for testing the WayVR/WiVRn desktop path.
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
}
