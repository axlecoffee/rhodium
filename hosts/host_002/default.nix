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
    ../../modules/desktop/wm/niri/intel.nix
    ../../modules/integration
    ../../modules/virtualization
    ../../modules/apps
    ../../modules/rules
    ../../modules/maintenance
    ../../modules/utils
  ];

  # Base
  # ---------------------------------
  # Kernel version
  boot.kernelPackages = pkgs.linuxPackages_6_12; # NVIDIA compatibility

  # Host Configuration
  networking = {
    hostName = "axlecoffee";
    networkmanager.enable = true;
  };

  # Modules
  # ---------------------------------
  # Extra Services
  extraServices = {
    asusKeyboardBacklight.enable = false;
    laptopLid.enable = false;
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
  system.stateVersion = "24.11";
}
