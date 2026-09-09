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


  # Fingerprint reader
  services.fprintd.enable = true;


  # ThinkPad fan control
  services.thinkfan = {
    enable = true;
  };


  # File synchronization
  services.syncthing = {
    enable = true;

    user = "tetra";

    #TODO: update file locations
    dataDir = "/media/syncthing/";

    configDir = "/home/tetra/.config/syncthing";
  };

  # Do not start Syncthing on the root filesystem if /media is not mounted.
  systemd.services.syncthing.serviceConfig.RequiresMountsFor = [
    "/media/syncthing"
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
