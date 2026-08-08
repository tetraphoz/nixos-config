{
  config,
  pkgs,
  ...
}:

{
  home.username = "tetra";
  home.homeDirectory = "/home/tetra";

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

    # Files

    thunar
    ranger

    # Development


    # Editors

    emacs
    neovim

    # Audio

    ardour
    hydrogen
    crosspipe
    qpwgraph
    mpd
    ncmpcpp
    cava
    reaper
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

  programs.git.settings = {
    user.name = "tetraphoz";
    user.email = "tetraphosphorus@gmail.com";
  
    init.defaultBranch = "main";
    pull.rebase = false;
  };

  programs.zsh.enable = true;

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

  # xdg.configFile."wal".source =
  #   ../dotfiles/wal;

  home.stateVersion = "26.05";
}
