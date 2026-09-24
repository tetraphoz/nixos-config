{ config, pkgs, ... }:

{
  # Hostname
  networking.hostName = "tetraphz";


  # Network management
  networking.networkmanager = {
    enable = true;
  };

  # Tailscale provides private remote access to the host.  Authenticate the
  # node once after switching with `sudo tailscale up`; no auth key is kept in
  # this repository.
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  # Manage Thunderbolt authorization for docks and other peripherals.
  services.hardware.bolt.enable = true;


  # Enable wireless firmware
  hardware.enableRedistributableFirmware = true;



  # Enable firewall
  networking.firewall = {
    enable = true;

    # SSH is key-only below. Use a non-standard port to reduce automated
    # scanning while keeping every other inbound service closed by default.
    allowedTCPPorts = [
      2222
      # 8096 # Jellyfin
    ];

    allowedUDPPorts = [
    ];
  };


  # SSH access
  services.openssh = {
    enable = true;
    ports = [ 2222 ];

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
    speedtest-cli
  ];
}
