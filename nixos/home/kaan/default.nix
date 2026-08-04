{ ... }:

{
  imports = [
    ./modules/caelestia.nix
    ./modules/shell.nix
    ./modules/apps.nix
    ./modules/dotfiles.nix
    ./modules/mimeapps.nix
  ];

  home = {
    username = "kaan";
    homeDirectory = "/home/kaan";
    stateVersion = "26.05";
  };
}
