{ config, pkgs, ... }:

{
  #
  # X11 / XMonad
  #
  services.xserver = {
    enable = true;

    displayManager.startx.enable = true;

    xkb = {
      layout = "us";
      variant = "altgr-intl";
    };

    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };
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
  # GPG / Pass
  #
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gtk2;
    enableSSHSupport = true;
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
