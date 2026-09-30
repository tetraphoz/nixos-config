{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    waybar
    wofi
    nwg-displays
    wl-clipboard
    grim
    slurp
    brightnessctl
    pavucontrol
    tesseract
    hyprlock
    hypridle
    hyprpaper
    hyprsunset
    hyprpicker
    pyprland
    swayosd
    jq
    font-awesome
    playerctl
    pywal16
  ];

  xdg.configFile."hypr/hyprland.conf".source = ../dotfiles/hypr/hyprland.conf;
  xdg.configFile."pypr/config.toml".source = ../dotfiles/hypr/pyprland.toml;
  xdg.configFile."hypr/hyprsunset.conf".source = ../dotfiles/hypr/hyprsunset.conf;
  xdg.configFile."hypr/hyprpaper.conf".text = ''
    # The wallpaper helper uses hyprctl to change outputs through Hyprpaper's IPC socket.
    ipc = on
    splash = false
  '';

  xdg.configFile."hypr/hypridle.conf".text = ''
    general {
      lock_cmd = pidof hyprlock || hyprlock
      before_sleep_cmd = loginctl lock-session
      after_sleep_cmd = hyprctl dispatch dpms on
      ignore_dbus_inhibit = false
    }

    # Lock after five minutes of inactivity; power off displays three minutes later.
    listener {
      timeout = 300
      on-timeout = loginctl lock-session
    }

    listener {
      timeout = 480
      on-timeout = hyprctl dispatch dpms off
      on-resume = hyprctl dispatch dpms on
    }
  '';

  xdg.configFile."hypr/hyprlock.conf".text = ''
    background {
      monitor =
      color = rgba(150816ff)
    }

    label {
      monitor =
      text = $TIME
      color = rgba(ffe7c2ff)
      font_size = 68
      font_family = IBM Plex Sans
      position = 0, 75
      halign = center
      valign = center
    }

    label {
      monitor =
      text = cmd[update:60000] date +"%A, %d %B"
      color = rgba(c7aebfff)
      font_size = 16
      font_family = IBM Plex Sans
      position = 0, 12
      halign = center
      valign = center
    }

    input-field {
      monitor =
      size = 300, 58
      outline_thickness = 2
      dots_size = 0.22
      dots_spacing = 0.35
      dots_center = true
      outer_color = rgba(ff8a3dff)
      inner_color = rgba(211522ff)
      font_color = rgba(ffe7c2ff)
      fade_on_empty = false
      placeholder_text = <i>Enter password</i>
      check_color = rgba(70c090ff)
      fail_color = rgba(e85d1aff)
      fail_text = <i>Authentication failed</i>
      rounding = 12
      position = 0, -36
      halign = center
      valign = center
    }
  '';
  # Bundle both files so Home Manager installs Waybar's config and stylesheet
  # through one directory link instead of linking files into a store-backed directory.
  xdg.configFile."waybar".source = pkgs.runCommand "tetra-waybar-config" { } ''
    mkdir -p "$out"
    cp ${../dotfiles/waybar/config} "$out/config"
    cat > "$out/style.css" <<'EOF'
    @import url("/home/tetra/.cache/wal/colors-waybar.css");

    * {
      border: none;
      border-radius: 0;
      font-family: "IBM Plex Sans", "Font Awesome 7 Free";
      font-size: 13px;
      min-height: 0;
    }

    window#waybar {
      background-color: alpha(@background, 0.94);
      color: @foreground;
      border-top: 1px solid alpha(@color2, 0.75);
    }

    tooltip {
      background-color: @background;
      color: @foreground;
      border: 1px solid @color2;
      border-radius: 10px;
    }

    #workspaces {
      margin: 4px 6px;
      padding: 2px;
      background-color: alpha(@background, 0.72);
      border-radius: 10px;
    }

    #workspaces button {
      min-width: 24px;
      padding: 0 9px;
      color: alpha(@foreground, 0.72);
      border-radius: 8px;
      transition: background-color 160ms ease, color 160ms ease;
    }

    #workspaces button:hover {
      background-color: alpha(@color2, 0.24);
      box-shadow: none;
    }

    #workspaces button.active {
      color: @foreground;
      background-color: alpha(@color2, 0.38);
      border-bottom: 2px solid @color2;
    }

    #window {
      margin-left: 8px;
      color: alpha(@foreground, 0.82);
    }

    #clock,
    #mpris,
    #backlight,
    #cpu,
    #memory,
    #temperature,
    #network,
    #pulseaudio,
    #battery,
    #tray {
      margin: 5px 3px;
      padding: 0 10px;
      background-color: alpha(@background, 0.72);
      border-radius: 9px;
    }

    #clock {
      padding: 0 14px;
      color: @foreground;
      background-color: alpha(@color2, 0.22);
      font-weight: 600;
    }

    #mpris {
      color: @foreground;
      background-color: alpha(@color5, 0.18);
    }

    #temperature.critical,
    #battery.critical {
      color: @color1;
      background-color: alpha(@color1, 0.18);
    }

    #battery.warning {
      color: @color3;
    }

    #pulseaudio.muted {
      color: alpha(@foreground, 0.58);
    }

    #tray {
      padding: 0 8px;
    }
    EOF
  '';

  home.file.".local/bin/hypr-window-picker" = {
    source = ../dotfiles/hypr/window-picker;
    executable = true;
  };

  home.file.".local/bin/hypr-screenshot" = {
    source = ../dotfiles/hypr/screenshot;
    executable = true;
  };

  home.file.".local/bin/hypr-workspace" = {
    source = ../dotfiles/hypr/workspace;
    executable = true;
  };

  home.file.".local/bin/hypr-virtual-output" = {
    source = ../dotfiles/hypr/virtual-output;
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
