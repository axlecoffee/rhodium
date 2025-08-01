{
  pkgs,
  users,
  ...
}:
let
  user_001_data =
    users.user_001 or {
      username = "user";
      fullName = "Default User";
      email = "user@example.com";
      description = "Default User";
      extraGroups = [ "wheel" ];
    };
in
{
  users.users."${user_001_data.username}" = {
    name = user_001_data.username;
    isNormalUser = user_001_data.isNormalUser or true;
    description = user_001_data.fullName;
    extraGroups = user_001_data.extraGroups;
    shell = pkgs.fish;
    home = "/home/${user_001_data.username}";
  };

  # NOTE: Required for devenv
  nix.settings.trusted-users = [
    "root"
    "axle"
  ];

  home-manager.backupFileExtension = "backup"; # HACK: Required since hm activation was sometimes faulty

  users.defaultUserShell = pkgs.zsh; # Default shell for all users
}
