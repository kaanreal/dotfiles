# System-level packages. Per-user apps live in nix/home/kaan/apps.nix.
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Base CLI
    git
    curl
    wget
    ripgrep
    jq

    pulseaudio

    # Windows SSD mount
    ntfs3g

    # Captured into the pressure-vessel container via the ld.so.cache (sw/lib is
    # scanned). osu-wine's Wine needs these to render and for fonts:
    #   - libglvnd: GLVND dispatchers (libEGL.so.1/libGL.so.1/libGLX.so.0) so
    #     Wine can create an EGL/GL context -> "no driver could be loaded".
    #   - vulkan-loader: libvulkan.so.1 -> "Failed to load libvulkan.so.1".
    #   - freetype: libfreetype.so.6 -> "Wine cannot find the FreeType font library".
    libglvnd
    vulkan-loader
    freetype
    # update-desktop-database for the osu-mime step of osu-winello
    desktop-file-utils
  ];
}
