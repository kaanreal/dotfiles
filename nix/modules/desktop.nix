# Desktop session: Hyprland, Qt theming, portals, and the Caelestia shell
# system bits (geoclue2 for the weather widget, polkit agent wrapper).
{ pkgs, lib, ... }:

{
  programs.hyprland.enable = true;

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita";
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-gtk
  ];

  # Stable audio pacing: keep every PipeWire client on a 48 kHz,
  # 1024-frame graph (~21.3 ms) instead of allowing buffer renegotiation that
  # can produce pops when clients such as JamesDSP join or leave the graph.
  services.pipewire.extraConfig.pipewire."92-stable-quantum" = {
    context.properties = {
      "default.clock.rate" = 48000;
      "default.clock.quantum" = 1024;
      "default.clock.min-quantum" = 1024;
      "default.clock.max-quantum" = 1024;
    };
  };

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
