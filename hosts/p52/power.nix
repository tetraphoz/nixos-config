{ config, pkgs, ... }:

{
  hardware.cpu.intel.updateMicrocode = true;

  # Intel thermal/power management
  services.throttled = {
    enable = true;

    extraConfig = ''
      [GENERAL]
      Enabled=True

      # Prevent excessive turbo throttling
      PL1=45
      PL2=60

      # Time window for turbo power
      Clamp=1

      # Undervolt values
      # Adjust after testing stability
      CORE=-100
      CACHE=-100
      GPU=-50
      SYSTEM_AGENT=0
      ANALOGIO=0

      # Battery behavior
      Battery=1
    '';
  };


  # Laptop power management
  services.tlp = {
    enable = true;

    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      WIFI_PWR_ON_BAT = "on";

      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";

      USB_AUTOSUSPEND = 1;
    };
  };

#Important: throttled + modern kernels There is a caveat: newer Linux kernels
#have restricted MSR writes because of security changes. If throttled fails, you
#may need:
#boot.kernelParams = [
#  "msr.allow_writes=on"
#];

  environment.systemPackages = with pkgs; [
    powertop
    acpi
    tlp
  ];
}
