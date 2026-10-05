{ config, pkgs, ... }:

let
  # Ly's generated session directory includes both upstream Hyprland entries.
  # Expose the direct one only, without rebuilding Hyprland just to hide a
  # desktop file from Ly's session picker.
  lyWaylandSessions = pkgs.runCommand "ly-wayland-sessions" { } ''
    mkdir -p "$out"
    for session in ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions/*.desktop; do
      [ -f "$session" ] || continue
      case "''${session##*/}" in
        hyprland-uwsm.desktop) continue ;;
      esac
      ln -s "$session" "$out/"
    done
  '';
in
{
  # XMonad remains the default Ly session; Hyprland is available as an
  # optional Wayland desktop for WiVRn and WayVR.
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.displayManager.ly.settings.waylandsessions = "${lyWaylandSessions}";
}
