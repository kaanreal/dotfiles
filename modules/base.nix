{ config, pkgs, lib, ... }:

{
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
    material-symbols
    rubik
    nerd-fonts.caskaydia-cove
  ];

  hardware.bluetooth.enable = true;

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    ripgrep
    jq
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };
}
