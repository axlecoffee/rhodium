{ pkgs, ... }:
{
  imports = [
    ./direnv.nix
  ];

  home.packages = with pkgs; [
    nix-btm # Bottom-like system monitor for nix
    nix-du # Disk usage analyzer for nix store
    nix-melt # Ranger-like flake.lock viewer
    nix-output-monitor # Better nix build output
    nix-prefetch-github # Prefetch sources from github. Useful for computing commit hashes.
    nix-search # Search nix packages
    nix-top # Top-like process monitor for nix
    nix-tree # Explore nix store
    nix-update # Update nix package versions
    nix-web # Web interface for nix store
  ];
}
