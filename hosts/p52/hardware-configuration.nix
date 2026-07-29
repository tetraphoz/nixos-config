{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];


  # Kernel modules needed during boot
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usb_storage"
    "sd_mod"
  ];

  boot.kernelModules = [
    "kvm-intel"
  ];


  # Intel CPU microcode
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;


  # Root filesystem
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/8be21a49-6ea2-4168-a1d1-c3f4fb2140fc";
    fsType = "ext4";
  };


  # EFI boot partition
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/2777-4C4D";
    fsType = "vfat";

    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };


  # Secondary NVMe drive
  fileSystems."/media" = {
    device = "/dev/disk/by-uuid/e666911d-9588-416e-b5e7-a646aab9c537";
    fsType = "ext4";
  };


  # Swap partition
  swapDevices = [
    {
      device = "/dev/disk/by-uuid/49d35180-02bf-4c39-b841-fb3b3b9c38e4";
    }
  ];


  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
