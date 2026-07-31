{ pkgs, lib, caelestia-shell, ... }:

{
  imports = [
    ./caelestia.nix
    caelestia-shell.homeManagerModules.default
  ];

  home = {
    username = "kaan";
    homeDirectory = "/home/kaan";
    stateVersion = "26.05";
  };
}
