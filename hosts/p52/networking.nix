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


  # DNS configuration
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];


  # Enable firewall
  networking.firewall = {
    enable = true;

    # Allow local services if needed
    allowedTCPPorts = [
      # 22 # SSH
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
