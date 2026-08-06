{ config, pkgs, ... }:

{
  programs.steam = {
    enable = true;

    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;

    package = pkgs.steam;

    extraPackages = with pkgs; [
      gamemode
      mangohud
      gamescope
    ];
  };

  environment.systemPackages = with pkgs; [
    jdk21
    prismlauncher      # Minecraft launcher
    mesa-demos         # glxinfo
    mangohud
    gamemode
    protontricks
    winetricks
  ];

  programs.gamemode.enable = true;
}
