{ config, pkgs, ... }:

{
  virtualisation.docker.enable = true;

  virtualisation.libvirtd.enable = true;

  programs.virt-manager.enable = true;

  environment.systemPackages = with pkgs; [
    docker-compose

    podman
    podman-compose

    qemu
    virt-manager
  ];


  users.users.tetra.extraGroups = [
    "docker"
    "libvirtd"
  ];
}
