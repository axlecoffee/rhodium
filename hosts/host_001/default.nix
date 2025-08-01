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
    ../../modules/desktop/wm/niri/amd.nix
    ../../modules/integration
    ../../modules/virtualization
    ../../modules/apps
    ../../modules/rules
    ../../modules/maintenance
    ../../modules/utils
  ];

  # Base
  # ---------------------------------
  # Kernel version (AMD follows latest)
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Host Configuration
  networking = {
    hostName = host.hostname or "nixos";
    networkmanager.enable = true;
  };

  # Modules
  # ---------------------------------
  # Display Manager
  manager = {
    gdm.enable = false;
  };

  # Extra Services
  extraServices = {
    asusKeyboardBacklight.enable = true;
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
  system.stateVersion = "24.05"; # NOTE: Original derivation
}
