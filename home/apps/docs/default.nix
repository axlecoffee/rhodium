{pkgs, ...}: {
  imports = [
    ./obsidian.nix
    ./okular.nix
    ./standardnotes.nix
    ./zathura.nix
  ];

  home.packages = with pkgs; [
    # anytype
    # appflowy
    # logseq
    # roam-research
    # joplin
    # joplin-desktop
    # notion-app
  ];
}
