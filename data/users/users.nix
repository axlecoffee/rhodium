{
  users = {
    user_001 = {
      username = "axle";
      fullName = "Axle";
      emailMain = "axle@example.com";
      extraGroups = [
        "wheel"
        "networkmanager"
        "docker"
        "input"
        "uinput"
        "video"
      ]; # NOTE: uinput required by kmonad
      isNormalUser = true;
      shell = "fish";
    };
  };
}
