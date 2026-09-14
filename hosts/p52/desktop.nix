{ config, pkgs, ... }:

let
  # Kitty ignores bitmap fonts and only accepts fonts that fontconfig marks as
  # monospaced. Cozette's vector font has fixed-width glyphs, but its metadata
  # does not advertise that fact, so make a Kitty-compatible copy at build
  # time. The visual design remains Cozette.
  pythonWithFontTools = pkgs.python3.withPackages (ps: [ ps.fonttools ]);
  cozetteForKitty = pkgs.stdenvNoCC.mkDerivation {
    pname = "cozette-vector-mono";
    version = "1.30.0";
    dontUnpack = true;

    installPhase = ''
      font="$out/share/fonts/opentype/CozetteVectorMono.otf"
      mkdir -p "$(dirname "$font")"
      cp ${pkgs.cozette}/share/fonts/opentype/CozetteVector.otf "$font"
      chmod u+w "$font"

      ${pythonWithFontTools}/bin/python - "$font" <<'PY'
      from fontTools.ttLib import TTFont
      import sys

      path = sys.argv[1]
      font = TTFont(path)
      cmap = font.getBestCmap()
      cell_width = font["hmtx"].metrics[cmap[ord("A")]][0]

      # Kitty requires a monospace font. Cozette's regular glyphs already use
      # this cell width; normalize uncommon/wide glyphs for terminal safety.
      for glyph_name, (_, left_side_bearing) in font["hmtx"].metrics.items():
          font["hmtx"].metrics[glyph_name] = (cell_width, left_side_bearing)

      font["post"].isFixedPitch = 1
      if "OS/2" in font:
          font["OS/2"].panose.bProportion = 9

      for record in font["name"].names:
          if record.nameID in (1, 4, 6, 16, 17):
              record.string = "CozetteVectorMono".encode(record.getEncoding())

      font.save(path)
      PY
    '';
  };
in
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

  # Reapply the layout on HDMI hotplug/unplug and resume.  The P52's HDMI
  # connector is exposed by the NVIDIA output provider as HDMI-1-0.  The
  # wildcard fingerprints keep this usable with another HDMI monitor while
  # still selecting the 4K mode for the monitor normally attached here.
  services.autorandr = {
    enable = true;
    defaultTarget = "default";

    profiles = {
      default = {
        fingerprint = {
          "eDP-1" = "*";
        };

        config = {
          "eDP-1" = {
            primary = true;
            position = "0x0";
            mode = "1920x1080";
            rate = "60.03";
          };
        };
      };

      hdmi-4k = {
        fingerprint = {
          "eDP-1" = "*";
          "HDMI-1-0" = "*";
        };

        config = {
          # Keep the laptop panel physically to the left of the main
          # external display.  The external display remains primary.
          "eDP-1" = {
            position = "0x0";
            mode = "1920x1080";
            rate = "60.03";
          };

          "HDMI-1-0" = {
            primary = true;
            position = "1920x0";
            mode = "3840x2160";
            rate = "60.00";
          };
        };
      };
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

    # Screenshots and OCR
    maim
    tesseract

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
      symbola
      cozetteForKitty
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
