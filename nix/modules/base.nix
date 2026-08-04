{
  config,
  pkgs,
  lib,
  ...
}:

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

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    # Members of wheel can use the daemon's store without sudo (nh builds as
    # the user; root privileges are only needed for the activation step).
    trusted-users = [
      "root"
      "@wheel"
    ];
  };
}
