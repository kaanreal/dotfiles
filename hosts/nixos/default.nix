{ config, pkgs, lib, nix-cachyos-kernel, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/base.nix
    ../../modules/gpu.nix
    ../../modules/hyprland.nix
    ../../modules/caelestia.nix
    ../../modules/tailscale.nix
  ];

services.flatpak.enable = true;

  # Windows SSD (Samsung 990 PRO) mounted at boot
  # ntfs-3g (FUSE) instead of ntfs3: more forgiving of dirty/hibernated volumes.
  fileSystems."/mnt/windows" = {
    device = "/dev/disk/by-uuid/34D6E186D6E148A6";
    fsType = "ntfs-3g";
    options = [
      "nofail"
      "rw"
      "uid=1000"
      "gid=100"
      "umask=022"
    ];
  };
  environment.systemPackages = with pkgs; [
    ntfs3g
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # X11/wayland session setup
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };
  console.keyMap = "de";

  services.printing.enable = true;  
  
  users.users.kaan = {
    isNormalUser = true;
    description = "kaan";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
      "input"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  # CachyOS kernel, zen4-optimized for the Ryzen 7 7800X3D.
  # Uses the caller's nixpkgs (overlays.default), so the rest of the system
  # is unaffected; the kernel itself is compiled locally on first rebuild.
  nixpkgs.overlays = [ nix-cachyos-kernel.overlays.default ];
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-zen4;

  # Binary cache for the CachyOS kernel flake
  nix.settings.substituters = [ "https://attic.xuyh0120.win/lantian" ];
  nix.settings.trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];

  # Cap compile parallelism (physical cores) so kernel builds fit in 15GB RAM
  nix.settings.cores = 8;

  system.stateVersion = "26.05";
}
