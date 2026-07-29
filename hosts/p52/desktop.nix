{ config, pkgs, ... }:

{
  # Desktop applications and themes
  environment.systemPackages = with pkgs; [
    # GTK configuration tool
    lxappearance

    # Icons
    numix-icon-theme
    numix-icon-theme-circle

    # GTK themes / engines
    flat-color-icons
    gtk-engine-murrine

    # Fonts
    ibm-plex
    gohufont
    tamzen
    fira-code
  ];

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
  };
}
