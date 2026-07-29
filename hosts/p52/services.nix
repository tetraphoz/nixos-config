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
    dataDir = "/home/tetra/Sync";

    configDir = "/home/tetra/.config/syncthing";
  };


  environment.systemPackages = with pkgs; [
    syncthing
    thinkfan
  ];
}
