{ config, pkgs, ... }:

{
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;

    alsa = {
      enable = true;
      support32Bit = true;
    };

    pulse.enable = true;
    jack.enable = true;

    wireplumber.enable = true;
  };

  # Realtime scheduling for audio work
  security.pam.loginLimits = [
    {
      domain = "@audio";
      type = "-";
      item = "memlock";
      value = "unlimited";
    }
    {
      domain = "@audio";
      type = "-";
      item = "rtprio";
      value = "95";
    }
  ];

  users.users.tetra.extraGroups = [
    "audio"
  ];

  environment.systemPackages = with pkgs; [
    pavucontrol
    qjackctl
    helvum
    easyeffects
    mpc
  ];
}
