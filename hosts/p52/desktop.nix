{ config, pkgs, ... }:

{
  #
  # X11 / XMonad
  #
  services.xserver = {
    enable = true;

    # Ly provides the graphical login and starts the XMonad session.
    displayManager.startx.enable = false;

    xkb = {
      layout = "us";
      variant = "altgr-intl";
    };

    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };
  };

  services.displayManager = {
    defaultSession = "none+xmonad";
    ly.enable = true;
  };

  #
  # Desktop applications, themes and utilities
  #
  environment.systemPackages = with pkgs; [
    # X11
    xinit
    arandr
    brightnessctl
    xclip
    libnotify

    # GTK
    lxappearance
    colloid-gtk-theme

    # Icons
    numix-icon-theme
    numix-icon-theme-circle

    # GTK engines
    gtk-engine-murrine

    # Screenshots
    maim

    # File manager and previews
    thunar-volman
    polkit_gnome
    vips
    imagemagick
    chafa
    ffmpegthumbnailer
    pkgs."poppler-utils"
    exiftool

    # X11 session utilities
    xsettingsd
    wmname

    # Fonts
    ibm-plex
    gohufont
    tamzen
    fira-code
    cozette

    # Secrets
    gnupg
    pass
  ];

  #
  # GNOME / GTK support
  #
  programs.dconf.enable = true;

  #
  # Screen sharing
  #
  programs.obs-studio = {
    enable = true;

    # optional Nvidia hardware acceleration
    package = (
      pkgs.obs-studio.override {
        cudaSupport = true;
      }
    );

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-vaapi #optional AMD hardware acceleration
      obs-gstreamer
      obs-vkcapture
    ];
  };

  #
  # GTK portals
  #
  xdg.portal = {
    enable = true;

    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];

    config.common.default = "*";
  };

  #
  # GPG / Pass / Security
  #
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gtk2;
    enableSSHSupport = true;

    # Keep SSH keys cached for a day by default, up to one week maximum.
    settings = {
      "default-cache-ttl-ssh" = 86400;
      "max-cache-ttl-ssh" = 604800;
    };
  };

  programs.slock.enable = true;

  #
  # Fonts
  #
  fonts = {
    packages = with pkgs; [
      ibm-plex
      gohufont
      tamzen
      fira-code
      cozette
    ];

    fontconfig = {
      enable = true;

      defaultFonts = {
        serif = [
          "IBM Plex Serif"
        ];

        sansSerif = [
          "IBM Plex Sans"
        ];

        monospace = [
          "Fira Code"
          "Tamzen"
        ];
      };
    };
  };
}
