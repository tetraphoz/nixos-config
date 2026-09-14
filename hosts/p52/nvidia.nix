{ config, pkgs, ... }:

{
  
  # Load NVIDIA driver for X11
  services.xserver.videoDrivers = [
    "nvidia"
  #  "modesetting"
  ];


  hardware.graphics = {
    enable = true;
  };

  hardware.nvidia.prime = {
    # The P52's HDMI connector is wired to the Quadro, while the internal
    # panel is wired to Intel (Reverse PRIME / OutputSink).  Normal PRIME
    # offload alone only exposes the Intel-connected outputs.
    reverseSync = {
      enable = true;

      # Ly does not implement displayManager.setupCommands; xinitrc attaches
      # NVIDIA-G0 to modesetting after the X session has a DISPLAY.
      setupCommands.enable = false;
    };

    # Reverse PRIME also provides render offload.  Keep the helper available
    # for applications that should render directly on the Quadro.
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

    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
  };


  environment.systemPackages = with pkgs; [
    nvidia-vaapi-driver
  ];
}
