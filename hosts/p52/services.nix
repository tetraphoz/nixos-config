{
  config,
  pkgs,
  ...
}:

{
  # Firmware updates
  services.fwupd.enable = true;

  # Printing
  services.printing.enable = true;

  # Fingerprint reader.  The P52 exposes a Synaptics Metallica MIS reader as
  # 06cb:009a; fprintd's stock libfprint does not list that product ID, so the
  # flake overlay supplies the small host-specific ID addition.
  services.fprintd = {
    enable = true;
    package = pkgs.fprintd-p52;
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

  environment.systemPackages = with pkgs; [
    syncthing
    thinkfan
  ];
}
