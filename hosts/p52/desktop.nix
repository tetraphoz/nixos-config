{ config, pkgs, ... }:

{

  services.xserver = {

    enable = true;

    displayManager.startx.enable = true;

    xkb.layout = "us";
    xkb.variant = "altgr-intl";

    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };
  };

  # Desktop applications and themes
  environment.systemPackages = with pkgs; [
    
    xinit
    arandr
    brightnessctl

    # GTK configuration tool
    lxappearance

    # Icons
    numix-icon-theme
    numix-icon-theme-circle

    # GTK themes / engines
    #flat-color-icons
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
    slock
  ];

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = with pkgs; pinentry-all;
    enableSSHSupport = true;
  };


  programs.slock.enable = true;

  # Font configuration
  fonts = {
    packages = with pkgs; [
      ibm-plex
      gohufont
      tamzen
      fira-code
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

  # GTK support
  programs = {
    dconf.enable = true;
  };

  # Optional: enable GTK portal support
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    config.common.default = "*";
  };
}
