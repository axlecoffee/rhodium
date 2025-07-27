{
  host,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/boot/boot.nix
    ../../modules/services
    ../../modules/hardware
    ../../modules/shell
    ../../modules/security
    ../../modules/users
    ../../modules/manager
    ../../modules/desktop
    ../../modules/desktop/wm/niri/intel.nix  # Intel + NVIDIA configuration
    ../../modules/integration
    ../../modules/virtualization
    ../../modules/apps
    ../../modules/rules
    ../../modules/maintenance
    ../../modules/utils
  ];

  # Base
  # ---------------------------------
  # Kernel version (Intel + NVIDIA requires specific kernel)
  boot.kernelPackages = pkgs.linuxPackages_6_12; # NVIDIA compatibility

  # Hostname
  networking.hostName = "axlecoffee";

  # Power management
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };

  # Hardware
  # ---------------------------------
  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
  };

  # Power
  power = {
    ups.enable = false;
    laptopLid.enable = true;
  };

  # Extra rules
  extraRules = {
    keychronUdev.enable = true;
    hdmiAutoSwitch.enable = true;
  };

  # Garbage override
  maintenance.garbageCollection = {
    enable = true;
    schedule = "daily";
    deleteOlderThan = "30d";
  };

  # Extra Args
  # ---------------------------------
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Original derivation
  system.stateVersion = "25.05";
}
