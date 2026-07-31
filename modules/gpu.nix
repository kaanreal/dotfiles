{ config, pkgs, lib, ... }:

{
  hardware.graphics.enable = true;

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    branch = "latest";
  };

  services.xserver.videoDrivers = [ "nvidia" ];
}
