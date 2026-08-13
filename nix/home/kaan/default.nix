{ ... }:

{
  imports = [
    ./caelestia.nix
    ./packages.nix
    ./dotfiles.nix
    ./mimeapps.nix
  ];

  home = {
    username = "kaan";
    homeDirectory = "/home/kaan";
    stateVersion = "26.05";
  };
}
