{ config, pkgs, ... }:

{
  hardware.cpu.intel.updateMicrocode = true;

  # Compressed RAM swap improves responsiveness under memory pressure while
  # avoiding unnecessary writes to the SSD. The disk swap remains available.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

  # Laptop power management
  services.tlp = {
    enable = true;

    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      WIFI_PWR_ON_BAT = "on";

      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";

      USB_AUTOSUSPEND = 1;
    };
  };

  # Periodically scrub the Btrfs filesystem shared by the mounted subvolumes.
  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/" ];
    interval = "monthly";
  };

  # Keep bounded hourly/daily snapshots of the root subvolume. The existing
  # /.snapshots subvolume provides the snapshot storage location.
  services.snapper = {
    persistentTimer = true;
    snapshotInterval = "hourly";
    cleanupInterval = "daily";

    configs.root = {
      SUBVOLUME = "/";
      ALLOW_USERS = [ "tetra" ];
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
      TIMELINE_LIMIT_HOURLY = 12;
      TIMELINE_LIMIT_DAILY = 7;
      TIMELINE_LIMIT_WEEKLY = 4;
      TIMELINE_LIMIT_MONTHLY = 6;
      TIMELINE_LIMIT_YEARLY = 1;
    };
  };

  environment.systemPackages = with pkgs; [
    powertop
    acpi
    tlp
  ];
}
