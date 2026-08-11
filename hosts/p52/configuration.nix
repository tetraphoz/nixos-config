{
  config,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix

    # Hardware / desktop
    ./desktop.nix
    ./power.nix
    ./nvidia.nix

    # Development environment
    ./development.nix
    ./emacs.nix

    # System services
    ./services.nix
    ./containers.nix
    ./networking.nix

    # Audio
    ./audio.nix
    ./music-production.nix

    # Games
    ./games.nix
  ];


  # System identity
  time.timeZone = "America/Monterrey";


  # Nix configuration
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };


  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Keep only recent generations
  boot.loader.systemd-boot.configurationLimit = 10;


  # Security
  security.apparmor.enable = true;


  # User
  users.users.tetra = {
    isNormalUser = true;

    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "docker"
      "libvirtd"
    ];

    shell = pkgs.zsh;
  };


  programs.zsh.enable = true;


  # Allow proprietary packages
  nixpkgs.config.allowUnfree = true;


  # Deal with libraries
  programs.nix-ld = {
    enable = true;
  
    libraries = with pkgs; [
      libX11
      libXext
      alsa-lib
      stdenv.cc.cc
    ];
  };


  # Useful base utilities
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl

    pciutils
    usbutils

    lm_sensors
    smartmontools
  ];


  system.stateVersion = "26.05";
}
