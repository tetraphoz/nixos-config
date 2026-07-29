{
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

    # WM

    xmobar
    rofi
    dunst
    picom
    redshift
    slock

    # Browsers

    firefox
    librewolf

    # Files

    thunar

    # Development


    # Editors

    emacs
    neovim

    # Audio

    ardour
    hydrogen
    helvum
    qpwgraph
    mpd
    ncmpcpp
    cava
    reaper

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

  programs.git.enable = true;

  programs.zsh.enable = true;

  programs.home-manager.enable = true;

  home.file.".xinitrc".source =
    ../dotfiles/xinitrc;

  home.file.".xmonad".source =
    ../dotfiles/xmonad;

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

  xdg.configFile."wal".source =
    ../dotfiles/wal;

  home.stateVersion = "26.05";
}
