{ pkgs, ... }:
{
  home.packages = with pkgs; [
    rstudio
  ];
}
