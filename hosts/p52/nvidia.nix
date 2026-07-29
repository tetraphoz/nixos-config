{ config, pkgs, ... }:

{
  # Load NVIDIA driver for X11
  services.xserver.videoDrivers = [
    "nvidia"
    "modesetting"
  ];


  hardware.graphics = {
    enable = true;
  };

  hardware.nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };

    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };


  hardware.nvidia = {
    # Enable modesetting (recommended for modern compositors and Xorg)
    modesetting.enable = true;

    # Power management
    powerManagement = {
      enable = true;
    };

    # Quadro P2000 Mobile uses proprietary driver
    open = false;

    # Install nvidia-settings
    nvidiaSettings = true;
  };


  environment.systemPackages = with pkgs; [
    nvidia-vaapi-driver
  ];
}
