{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    waybar
    wofi
    nwg-displays
    wl-clipboard
    grim
    slurp
    hyprlock
    hyprpaper
  ];

  xdg.configFile."hypr/hyprland.conf".source = ../dotfiles/hypr/hyprland.conf;
  xdg.configFile."waybar".source = ../dotfiles/waybar;

  home.file.".local/bin/hypr-window-picker" = {
    source = ../dotfiles/hypr/window-picker;
    executable = true;
  };

  home.file.".local/bin/hypr-scratchpad" = {
    source = ../dotfiles/hypr/scratchpad;
    executable = true;
  };

  home.file.".local/bin/hypr-toggle-border" = {
    source = ../dotfiles/hypr/toggle-border;
    executable = true;
  };

  home.file.".local/bin/hypr-random-wallpaper" = {
    source = ../dotfiles/hypr/random-wallpaper;
    executable = true;
  };

  # nwg-displays manages this mutable include outside the Nix store. Seed it
  # with the preferred mode on first activation; the GUI can then update it.
  home.activation.initializeHyprlandMonitors = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    HYPR_MONITORS="$HOME/.config/hypr/monitors.conf"
    if [ ! -e "$HYPR_MONITORS" ]; then
      mkdir -p "$(dirname "$HYPR_MONITORS")"
      printf '%s\n' 'monitor = DP-3, 2560x1440@59.95, auto, 1.5' \
        > "$HYPR_MONITORS"
    fi
  '';
}
