{ config, pkgs, lib, ... }:

{
  programs.hyprland.enable = true;

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita";
  };
}
