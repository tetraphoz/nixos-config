{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Firmware updates
  services.fwupd.enable = true;

  # Printing
  services.printing.enable = true;

  # Sunshine exposes the active X11 desktop to Moonlight clients.  It runs as
  # the logged-in user through the graphical-session target, so it can access
  # this host's display and audio session without a separate service account.
  services.sunshine = {
    enable = true;
    openFirewall = true;

    # Allow Sunshine's preferred DRM/KMS capture path.  This is needed for
    # reliable capture with the P52's NVIDIA/PRIME display setup.
    capSysAdmin = true;
  };

  # Fingerprint reader.  The P52's 06cb:009a device is one of the Validity
  # sensors supported by python-validity.  It is not a normal libfprint device;
  # open-fprintd provides the fprintd DBus API and python-validity supplies the
  # sensor backend and firmware protocol.
  services.fprintd = {
    # Do not start the stock fprintd/libfprint daemon.  Its Synaptics driver is
    # not the driver required by this reader, but its PAM module and command
    # line clients are still useful below.
    enable = false;
    package = pkgs.fprintd;
  };

  services.dbus.packages = [
    pkgs.open-fprintd-p52
    pkgs.python-validity
  ];

  services.udev.packages = [ pkgs.python-validity ];

  environment.systemPackages = with pkgs; [
    # fprintd supplies fprintd-enroll/list/verify and pam_fprintd.so.
    fprintd
    open-fprintd-p52
    python-validity
    innoextract

    syncthing
    thinkfan
  ];

  # These units are defined explicitly because the units shipped by the
  # upstream packages contain /usr paths, which do not exist in the Nix store.
  systemd.services.open-fprintd = {
    description = "Open FPrint Daemon";
    after = [ "dbus.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "dbus";
      BusName = "net.reactivated.Fprint";
      ExecStart = "${pkgs.open-fprintd-p52}/lib/open-fprintd/open-fprintd --debug";
    };
  };

  systemd.services.python3-validity = {
    description = "python-validity fingerprint sensor DBus service";
    after = [ "open-fprintd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.python-validity}/lib/python-validity/dbus-service --debug";
      Restart = "on-failure";
      RestartSec = 2;
    };
  };

  # The sensor needs to be reinitialized after suspend/resume.  These are the
  # companion units shipped by open-fprintd, with their /usr paths replaced by
  # the actual Nix store paths.
  systemd.services.open-fprintd-suspend = {
    description = "Reset fingerprint backend before suspend";
    before = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" "suspend-then-hibernate.target" ];
    wantedBy = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" "suspend-then-hibernate.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.open-fprintd-p52}/lib/open-fprintd/suspend.py";
    };
  };

  systemd.services.open-fprintd-resume = {
    description = "Restart fingerprint backend after resume";
    after = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" "suspend-then-hibernate.target" ];
    wantedBy = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" "suspend-then-hibernate.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.open-fprintd-p52}/lib/open-fprintd/resume.py";
    };
  };

  # Enable the PAM module independently of services.fprintd.enable: the
  # module talks to open-fprintd through the same fprintd DBus API.
  security.pam.services = {
    login.fprintAuth = true;
    # Make Ly fingerprint-only: do not keep the normal password fallback in
    # the display-manager PAM stack.  Password authentication remains enabled
    # for TTY login, sudo, and the other PAM services below.
    ly = {
      fprintAuth = true;
      # Ly's module enables unixAuth by default, so explicitly override it.
      unixAuth = lib.mkForce false;
    };
    sudo.fprintAuth = true;
    "polkit-1".fprintAuth = true;
  };

  # ThinkPad P52 fan control.  The P52 exposes two physical fans and its
  # CPU/GPU temperatures through hwmon; thinkpad_acpi provides the single EC
  # control for the fan pair.  Use hwmon names instead of hwmonN paths because
  # the latter change with driver load order.
  boot.kernelModules = [ "thinkpad_acpi" ];

  services.thinkfan = {
    enable = true;

    sensors = [
      # Include every core so a hot core, rather than an average temperature,
      # can increase the fan level.
      {
        type = "hwmon";
        query = "/sys/class/hwmon";
        name = "coretemp";
        indices = [
          1
          2
          3
          4
          5
          6
          7
        ];
      }

      # The P52 hwmon driver exposes CPU as temp1 and the Quadro GPU as temp2.
      {
        type = "hwmon";
        query = "/sys/class/hwmon";
        name = "thinkpad";
        indices = [
          1
          2
        ];
      }
    ];

    # tpacpi is the P52's reliable fan-control interface; a single tpacpi
    # control changes the EC-managed fan pair together.
    fans = [
      {
        type = "tpacpi";
        query = "/proc/acpi/ibm/fan";
      }
    ];

    # Conservative hysteresis avoids rapid level changes while keeping the
    # CPU/GPU well below their thermal limits.  "level auto" returns control
    # to the EC on sustained high temperature loads as a safety measure.
    levels = [
      [
        0
        0
        55
      ]
      [
        1
        48
        60
      ]
      [
        2
        50
        61
      ]
      [
        3
        52
        63
      ]
      [
        6
        56
        65
      ]
      [
        7
        60
        85
      ]
      [
        "level auto"
        80
        32767
      ]
    ];
  };

  # File synchronization
  services.syncthing = {
    enable = true;

    # Permit Syncthing's discovery and peer traffic through the host firewall.
    openDefaultPorts = true;

    user = "tetra";

    #TODO: update file locations
    dataDir = "/media/syncthing/";

    configDir = "/home/tetra/.config/syncthing";
  };

  # Do not start Syncthing on the root filesystem if /media is not mounted.
  systemd.services.syncthing.serviceConfig.RequiresMountsFor = [
    "/media/syncthing"
    "/home/tetra"
  ];

  # Files
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  security.polkit.enable = true;

  services.locate.enable = true;

}
