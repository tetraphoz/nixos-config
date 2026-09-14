{ config, pkgs, ... }:

{
  virtualisation.docker.enable = true;

  virtualisation.libvirtd.enable = true;

  # The default libvirt NAT network belongs to the system daemon.  Without
  # this, virsh and virt-manager may connect to qemu:///session instead,
  # where the system's `default` network does not exist.
  environment.variables.LIBVIRT_DEFAULT_URI = "qemu:///system";

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
