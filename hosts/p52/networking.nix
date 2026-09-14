{ config, pkgs, ... }:

{
  # Hostname
  networking.hostName = "tetraphz";


  # Network management
  networking.networkmanager = {
    enable = true;
  };


  # Enable wireless firmware
  hardware.enableRedistributableFirmware = true;



  # Enable firewall
  networking.firewall = {
    enable = true;

    # SSH is key-only below, so expose it for administration while keeping
    # every other inbound service closed by default.
    allowedTCPPorts = [
      22
      # 8096 # Jellyfin
    ];

    allowedUDPPorts = [
    ];
  };


  # SSH access
  services.openssh = {
    enable = true;

    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };


  # Bluetooth
  hardware.bluetooth = {
    enable = true;
  };

  services.blueman.enable = true;


  # Networking utilities
  environment.systemPackages = with pkgs; [
    networkmanagerapplet

    iw
    wirelesstools

    ethtool

    tcpdump
    nmap

    curl
    wget

    traceroute
    mtr

    dnsutils
  ];
}
