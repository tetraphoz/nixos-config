{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    xmobar
    rofi
    picom
    redshift
    xss-lock
    xidlehook
    flameshot
    feh
    pywal16
  ];

  home.file.".xinitrc".source = ../dotfiles/xinitrc;

  # Ly launches the X session through .xsession instead of startx/.xinitrc.
  home.file.".xsession" = {
    source = ../dotfiles/xinitrc;
    executable = true;
  };

  # Keep the legacy default path in sync too. Xmobar without an explicit
  # config path reads ~/.xmobarrc.
  home.file.".xmobarrc".source = ../dotfiles/xmobarrc;

  # Keep the generated XMonad build directory writable so xmonad --recompile
  # can write its build output outside the read-only Nix store.
  home.file.".xmonad/xmonad.hs".source = ../dotfiles/xmonad/xmonad.hs;

  home.activation.linkWalColors = config.lib.dag.entryAfter [ "writeBoundary" ] ''
          mkdir -p "$HOME/.xmonad/lib"
          if [ -f "$HOME/.cache/wal/Colors.hs" ]; then
            ln -sfn "$HOME/.cache/wal/Colors.hs" \
              "$HOME/.xmonad/lib/Colors.hs"
          elif [ ! -e "$HOME/.xmonad/lib/Colors.hs" ]; then
            cat > "$HOME/.xmonad/lib/Colors.hs" <<'EOF'
    module Colors where

    background = "#17081e"
    foreground = "#c4c3c4"

    color0 = "#17081e"
    color1 = "#ff5555"
    color2 = "#50fa7b"
    color3 = "#f1fa8c"
    color4 = "#bd93f9"
    color5 = "#ff79c6"
    color6 = "#8be9fd"
    color7 = "#c4c3c4"
    color8 = "#6272a4"
    color9 = "#ff6e6e"
    EOF
          fi
  '';

  xdg.configFile."wal/templates".source = ../dotfiles/wal/templates;
  xdg.configFile."xmobar/xmobarrc".source = ../dotfiles/xmobarrc;
  xdg.configFile."rofi".source = ../dotfiles/rofi;
  xdg.configFile."picom".source = ../dotfiles/picom;
}
