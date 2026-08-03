{ config, pkgs, lib, nix-cachyos-kernel, ... }:

let
  # Replicates programs.nix-ld's library env, but at a /nix/store path.
  # The module's default NIX_LD* point at /run/current-system/sw/share/nix-ld,
  # which does not exist inside the pressure-vessel container (only /nix is
  # mounted), making nix-ld panic with ENOENT there. /nix/store paths work both
  # on the host and inside the container.
  nix-ld-libraries = pkgs.buildEnv {
    name = "nix-ld-libraries";
    pathsToLink = [ "/lib" ];
    paths = map lib.getLib [
      pkgs.zlib pkgs.zstd pkgs.stdenv.cc.cc pkgs.curl pkgs.openssl
      pkgs.attr pkgs.libssh pkgs.bzip2 pkgs.libxml2 pkgs.acl
      pkgs.libsodium pkgs.util-linux pkgs.xz pkgs.systemd
    ];
    extraPrefix = "/share/nix-ld";
    ignoreCollisions = true;
    postBuild = ''
      ln -s ${pkgs.stdenv.cc.bintools.dynamicLinker} $out/share/nix-ld/lib/ld.so
    '';
  };
in
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
  services.displayManager.gdm.enable = false;
  services.displayManager.ly.enable = true;
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

  # Run generic Linux binaries that expect an FHS-style dynamic linker path
  # (e.g. the Steam Runtime / pressure-vessel used by yawl/osu-winello).
  programs.nix-ld.enable = true;

  # pressure-vessel also runs i386 ELF binaries
  # (i386-linux-gnu-capsule-capture-libs) to capture 32-bit libs. The nix-ld
  # module only wires the x86_64 loader. The 32-bit loader MUST be the i686
  # build of nix-ld: an x86_64 nix-ld only ever reads NIX_LD_x86_64_linux and
  # would serve the x86_64 ld.so to 32-bit binaries ("Accessing a corrupted
  # shared library").
  environment.ldso32 = "${pkgs.pkgsi686Linux.nix-ld}/libexec/nix-ld";
  environment.sessionVariables = {
    NIX_LD = lib.mkForce "${nix-ld-libraries}/share/nix-ld/lib/ld.so";
    NIX_LD_LIBRARY_PATH = lib.mkForce "${nix-ld-libraries}/share/nix-ld/lib";
    NIX_LD_i686_linux = lib.mkForce "${pkgs.pkgsi686Linux.stdenv.cc.bintools.dynamicLinker}";
    NIX_LD_LIBRARY_PATH_i686_linux =
      lib.mkForce (lib.makeLibraryPath [ pkgs.pkgsi686Linux.glibc ]);
  };

  # pressure-vessel's container test execs /bin/true and needs basic tools at
  # FHS locations (/bin, /usr/bin) that NixOS doesn't provide. Symlink the
  # essentials. Targets MUST be /nix/store paths: /run/current-system/sw/bin
  # doesn't exist inside the container, so those symlinks break (execvp ENOENT).
  systemd.tmpfiles.rules =
    let
      link = pkg: prefix: bin: "L+ ${prefix}/${bin} - - - - ${pkg}/bin/${bin}";
      mk = pkg: prefix: bins: map (link pkg prefix) bins;
    in
      mk pkgs.coreutils "/bin" [ "true" "false" "echo" ]
      ++ mk pkgs.bash "/bin" [ "bash" ]
      ++ mk pkgs.util-linux "/bin" [ "mount" "umount" ]
      ++ mk pkgs.coreutils "/usr/bin" [ "true" "false" "echo" "env" "cat" "cp"
        "rm" "mkdir" "touch" "readlink" "stat" "ls" "head" "tail" "cut" "tr"
        "wc" "dirname" "basename" "mktemp" "ln" "id" "uname" ]
      ++ mk pkgs.bash "/usr/bin" [ "sh" "bash" ]
      ++ mk pkgs.util-linux "/usr/bin" [ "mount" "umount" ]
      ++ mk pkgs.gnused "/usr/bin" [ "sed" ]
      ++ mk pkgs.gnugrep "/usr/bin" [ "grep" ]
      ++ mk pkgs.findutils "/usr/bin" [ "find" ]
      ++ mk pkgs.glibc.bin "/usr/bin" [ "ldconfig" "ldd" "locale" "localedef" ]
      ++ mk pkgs.getent "/usr/bin" [ "getent" ];

  # Put the FHS dirs on PATH so pressure-vessel/bwrap find `true` & co inside
  # the container (it inherits the parent environment's PATH).
  environment.variables.PATH = [ "/usr/bin" "/bin" ];

  # pressure-vessel's capsule-capture-libs opens the ld.so.cache to figure out
  # which libraries to copy into the container. NixOS ships none, so generate
  # one at boot covering the GL/Vulkan driver dir and system libs. Provide it
  # at both locations the tool probes.
  system.activationScripts.ldsocache.text = ''
    mkdir -p /var/cache/ldconfig
    CACHE=/var/cache/ldconfig/ld.so.cache
    dirs="/run/opengl-driver/lib /run/current-system/sw/lib"
    for d in /run/opengl-driver-32/lib; do
      [ -d "$d" ] && dirs="$dirs $d"
    done
    ${pkgs.glibc.bin}/bin/ldconfig -C $CACHE $dirs
    ln -sfn $CACHE /etc/ld.so.cache
  '';

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
