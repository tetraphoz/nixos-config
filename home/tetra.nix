{
  config,
  pkgs,
  ...
}:

{
  home.username = "tetra";
  home.homeDirectory = "/home/tetra";

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
  ];

  home.sessionVariables = {
    BROWSER = "librewolf";
    EDITOR = "emacsclient";
    VISUAL = "emacsclient";
    # User plug-ins take precedence; the system profile contains the
    # Nix-managed VST/LV2/CLAP plug-ins from music-production.nix.
    VST_PATH = "/media/audio/vst:/run/current-system/sw/lib/vst";
    VST3_PATH = "/media/audio/vst3:/run/current-system/sw/lib/vst3";
    CLAP_PATH = "/media/audio/clap:/run/current-system/sw/lib/clap";
    LV2_PATH = "/media/audio/lv2:/run/current-system/sw/lib/lv2";
    LADSPA_PATH = "/media/audio/ladspa:/run/current-system/sw/lib/ladspa";
    DSSI_PATH = "/media/audio/dssi:/run/current-system/sw/lib/dssi";
    SOUND_FONT_PATH = "/media/audio/samples/soundfonts";
  };

  home.packages = with pkgs; [

    # Terminal

    kitty
    procps # provides pkill
    tmux
    zoxide
    fzf
    ripgrep
    fd
    jq
    yq
    btop

    # WM

    xmobar
    rofi
    dunst
    picom
    redshift
    xss-lock
    xidlehook
    pywal16

    # Browsers

    librewolf
    browserpass

    # Files

    thunar
    ranger
    yazi
    sxiv

    # Development


    # Editors

    emacs
    neovim

    # Audio

    mpd
    ncmpcpp
    cava
    spotify
    nicotine-plus
    beets

    # Video

    mpv
    davinci-resolve

    # Graphics

    gimp
    inkscape
    darktable
    rawtherapee
    krita
    blender

    # Documents

    libreoffice
    zathura
    typst
    pandoc

    # Networking

    wireshark
    nmap
    tcpdump
    qbittorrent

    # Sync

    # SDR

    rtl-sdr
    gqrx

    # Security

    keepassxc

    # Misc

    flameshot
    feh
    yt-dlp
    rclone
  ];

  gtk = {
    enable = true;
  
    theme = {
      name = "Colloid-Dark";
      package = pkgs.colloid-gtk-theme;
    };
  
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  programs.git = {
    enable = true;

    settings = {
      user.name = "tetraphoz";
      user.email = "tetraphosphorus@gmail.com";
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };

  programs.zsh = {
    enable = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;

    history = {
      size = 100000;
      save = 100000;
      ignoreDups = true;
      share = true;
      extended = true;
    };

    shellAliases = {
      ns = "sudo nixos-rebuild switch --flake /etc/nixos#p52";
      nst = "sudo nixos-rebuild test --flake /etc/nixos#p52";
      nfu = "cd /etc/nixos && sudo nix flake update";
  
      ".." = "cd ..";
      ll = "ls -lah";
      g = "git";
      lg = "lazygit";
      j = "just";
      v = "nvim";
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.browserpass.enable = true;

  programs.home-manager.enable = true;

  # Pi keeps its settings outside XDG_CONFIG_HOME.  Update only the model
  # preference so Pi can still manage the rest of this mutable settings file.
  home.activation.configurePi =
    config.lib.dag.entryAfter [ "writeBoundary" ] ''
      PI_SETTINGS="$HOME/.pi/agent/settings.json"
      mkdir -p "$(dirname "$PI_SETTINGS")"

      if [ -f "$PI_SETTINGS" ]; then
        tmp="$(mktemp)"
        if ${pkgs.jq}/bin/jq \
          '.defaultProvider = "openai" | .defaultModel = "gpt-6-luna"' \
          "$PI_SETTINGS" > "$tmp"; then
          chmod --reference="$PI_SETTINGS" "$tmp" 2>/dev/null || true
          if ! cmp -s "$tmp" "$PI_SETTINGS"; then
            mv "$tmp" "$PI_SETTINGS"
          else
            rm -f "$tmp"
          fi
        else
          rm -f "$tmp"
          echo "warning: could not update Pi settings; leaving them unchanged" >&2
        fi
      else
        printf '%s\\n' \
          '{"defaultProvider":"openai","defaultModel":"gpt-6-luna"}' \
          > "$PI_SETTINGS"
      fi
    '';

  # Run the Doom-managed Emacs daemon as the user, so emacsclient can reach
  # the same configuration and authentication agent as the desktop session.
  services.emacs = {
    enable = true;
    package = pkgs.emacs;

    # Ly starts X after the user manager is already up.  Starting the PGTK
    # daemon from default.target makes Emacs initialize without a window
    # system, so emacsclient cannot create X11 frames later.
    startWithUserSession = "graphical";
  };

  services.mpd = {
    enable = true;
  
    musicDirectory = "/media/music";
  
    network = {
      listenAddress = "127.0.0.1";
      port = 6600;
    };
  
    extraConfig = ''
      audio_output {
        type "pipewire"
        name "PipeWire"
      }
  
      audio_output {
        type "fifo"
        name "Visualizer"
        path "/tmp/mpd.fifo"
        format "44100:16:2"
      }

      auto_update "yes"
      restore_paused "yes"
      replaygain "album"
      filesystem_charset "UTF-8"
    '';
  };

  # Do not start MPD before the separate media filesystem is available.
  systemd.user.services.mpd.Unit.RequiresMountsFor = [ "/media/music" ];

  home.file.".xinitrc".source =
    ../dotfiles/xinitrc;

  # Ly launches the X session through .xsession instead of startx/.xinitrc.
  home.file.".xsession" = {
    source = ../dotfiles/xinitrc;
    executable = true;
  };

  # Keep the legacy default path in sync too.  Xmobar launched without an
  # explicit config path reads ~/.xmobarrc.
  home.file.".xmobarrc".source = ../dotfiles/xmobarrc;

  # Keep the generated XMonad build directory writable.  Managing the whole
  # directory as one Home Manager symlink makes xmonad --recompile try to
  # write into the read-only Nix store.
  home.file.".xmonad/xmonad.hs".source = ../dotfiles/xmonad/xmonad.hs;

  home.activation.linkWalColors =
    config.lib.dag.entryAfter [ "writeBoundary" ] ''
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


  home.file.".doom.d".source =
    ../dotfiles/doom.d;

  #home.file.".emacs.d".source =
  #  ../dotfiles/.emacs.d;


  xdg.configFile."kitty".source =
    ../dotfiles/kitty;

  xdg.configFile."mpv".source =
    ../dotfiles/mpv;

  xdg.configFile."wal/templates".source =
    ../dotfiles/wal/templates;

  xdg.configFile."xmobar/xmobarrc".source =
    ../dotfiles/xmobarrc;

  xdg.configFile."rofi".source =
    ../dotfiles/rofi;

  xdg.configFile."dunst".source =
    ../dotfiles/dunst;

  xdg.configFile."picom".source =
    ../dotfiles/picom;

  xdg.configFile."ncmpcpp".source =
    ../dotfiles/ncmpcpp;

  # Use dedicated desktop applications when opening files from Yazi.  Yazi's
  # built-in image preview remains available in the preview pane, while Enter
  # opens images in sxiv and audio files in a detached mpv window.
  xdg.configFile."yazi/yazi.toml".text = ''
    [opener]
    edit = [
      { run = "''${EDITOR:-vi} \"$@\"", block = true, desc = "Edit", for = "unix" },
    ]
    image = [
      { run = "sxiv \"$@\"", orphan = true, desc = "Open image", for = "unix" },
    ]
    play = [
      { run = "mpv --no-terminal --force-window=yes -- \"$@\"", orphan = true, desc = "Play with mpv", for = "unix" },
    ]
    open = [
      { run = "xdg-open \"$1\"", orphan = true, desc = "Open", for = "linux" },
    ]

    [open]
    rules = [
      { mime = "text/*", use = "edit" },
      { mime = "application/json", use = "edit" },
      { mime = "image/*", use = "image" },
      { mime = "video/*", use = "play" },
      { mime = "audio/*", use = "play" },
      { mime = "application/pdf", use = "open" },
      { mime = "*/*", use = "open" },
    ]
  '';

  xdg.desktopEntries.renoise = {
    name = "Renoise";
    genericName = "Digital Audio Workstation";
    comment = "Music production and tracker DAW";
    exec = "renoise %U";
    terminal = false;
    categories = [ "AudioVideo" "Audio" ];
  };

  home.file.".local/bin/renoise" = {
      executable = true;
      text = ''
      #!/usr/bin/env bash
      exec "${config.home.homeDirectory}/Applications/Renoise/renoise" "$@"
      '';
  };

  home.activation.installRofipass =
    config.lib.dag.entryAfter [ "writeBoundary" ] ''
      ROFIPASS_DIR="$HOME/.local/share/rofipass"
      ROFIPASS_BIN="$HOME/.local/bin/rofipass"
  
      if [ ! -d "$ROFIPASS_DIR/.git" ]; then
        mkdir -p "$(dirname "$ROFIPASS_DIR")"
        if ! ${pkgs.git}/bin/git clone \
          https://codeberg.org/aocoronel/rofipass \
          "$ROFIPASS_DIR"; then
          echo "warning: rofipass could not be downloaded; continuing without it" >&2
        fi
      fi

      if [ -x "$ROFIPASS_DIR/src/rofipass" ]; then
        mkdir -p "$(dirname "$ROFIPASS_BIN")"
        chmod 700 "$ROFIPASS_DIR/src/rofipass"
        ln -sfn "$ROFIPASS_DIR/src/rofipass" "$ROFIPASS_BIN"
      fi
    '';

  # xdg.configFile."wal".source =
  #   ../dotfiles/wal;

  home.stateVersion = "26.05";
}
