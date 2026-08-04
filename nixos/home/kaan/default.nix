{ pkgs, lib, caelestia-shell, ... }:

{
  imports = [
    ./modules/shell.nix
    ./modules/dotfiles.nix
    ./modules/apps.nix
    ./modules/mimeapps.nix
  ];

  home = {
    username = "kaan";
    homeDirectory = "/home/kaan";
    stateVersion = "26.05";
  };
}
