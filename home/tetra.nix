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
    VST_PATH = "/media/audio/vst";
    VST3_PATH = "/media/audio/vst3";
    LV2_PATH = "/media/audio/lv2";
  };

  home.packages = with pkgs; [

    # Terminal

    kitty
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
    xidlehook
    pywal16

    # Browsers

    librewolf
    browserpass

    # Files

    thunar
    ranger

    # Development


    # Editors

    emacs
    neovim

    # Audio

    mpd
    ncmpcpp
    cava
    spotify

    # Video

    mpv
    obs-studio

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

    syncthing

    # SDR

    rtl-sdr
    gqrx

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

  programs.git.settings = {
    user.name = "tetraphoz";
    user.email = "tetraphosphorus@gmail.com";
  
    init.defaultBranch = "main";
    pull.rebase = false;
  };

  programs.zsh = {
    enable = true;

    initContent = ''
      export PATH="$HOME/.local/bin:$PATH"
    '';
  
    shellAliases = {
      ns = "sudo nixos-rebuild switch --flake /etc/nixos#p52";
      nst = "sudo nixos-rebuild test --flake /etc/nixos#p52";
      nfu = "cd /etc/nixos && sudo nix flake update";
  
      ".." = "cd ..";
      ll = "ls -lah";
      g = "git";
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
  
      auto_update "yes"
      restore_paused "yes"
      replaygain "album"
      filesystem_charset "UTF-8"
    '';
  };

  home.file.".xinitrc".source =
    ../dotfiles/xinitrc;

  home.file.".xmonad" = {
      source = ../dotfiles/xmonad;
      recursive = true;
      force = true;
  };

  home.activation.makeXmonadWritable =
     config.lib.dag.entryAfter [ "writeBoundary" ] ''
     chmod -R u+w $HOME/.xmonad
  '';

  home.activation.linkWalColors =
    config.lib.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "$HOME/.xmonad/lib"
      ln -sfn "$HOME/.cache/wal/Colors.hs" \
        "$HOME/.xmonad/lib/Colors.hs"
    '';


  home.file.".doom.d".source =
    ../dotfiles/doom.d;

  #home.file.".emacs.d".source =
  #  ../dotfiles/.emacs.d;


  xdg.configFile."kitty".source =
    ../dotfiles/kitty;

  xdg.configFile."rofi".source =
    ../dotfiles/rofi;

  xdg.configFile."dunst".source =
    ../dotfiles/dunst;

  xdg.configFile."picom".source =
    ../dotfiles/picom;

  xdg.configFile."mpd".source =
    ../dotfiles/mpd;

  xdg.configFile."ncmpcpp".source =
    ../dotfiles/ncmpcpp;

  home.activation.copyWal =
     config.lib.dag.entryAfter [ "writeBoundary" ] ''
       mkdir -p $HOME/.config/wal
       cp -r ${../dotfiles/wal}/* $HOME/.config/wal/
       chmod -R u+w $HOME/.config/wal
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
        ${pkgs.git}/bin/git clone \
          https://codeberg.org/aocoronel/rofipass \
          "$ROFIPASS_DIR"
      fi
  
      chmod 700 "$ROFIPASS_DIR/src/rofipass"
      ln -sf "$ROFIPASS_DIR/src/rofipass" "$ROFIPASS_BIN"
    '';

  # xdg.configFile."wal".source =
  #   ../dotfiles/wal;

  home.stateVersion = "26.05";
}
