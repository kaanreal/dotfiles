{ config, pkgs, lib, ... }:

{
  # Geolocation agent used by the Caelestia shell (weather etc.)
  services.geoclue2 = {
    enable = true;
    enableDemoAgent = lib.mkForce true;
  };

  # Polkit authentication agent for the Hyprland session.
  # The dots' execs.lua calls the bare command name, so we provide a wrapper.
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "polkit-gnome-authentication-agent-1" ''
      exec ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
    '')
  ];
}
