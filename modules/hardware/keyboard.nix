{ pkgs, ... }:
# TODO: Dynamic
{
  environment.systemPackages = with pkgs; [
    xorg.xev # xorg key registry
  ];

  time.timeZone = "Europe/London"; # Time zone
  i18n.defaultLocale = "en_US.UTF-8"; # Locale

  # Additional properties
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  console.keyMap = "us"; # Default console Keymap

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # NOTE: Required for kmonad
  hardware.uinput = {
    enable = true;
  };
}
