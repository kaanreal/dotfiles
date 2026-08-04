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
    paths = map lib.getLib (
      [
        pkgs.zlib pkgs.zstd pkgs.stdenv.cc.cc pkgs.curl pkgs.openssl
        pkgs.attr pkgs.libssh pkgs.bzip2 pkgs.libxml2 pkgs.acl
        pkgs.libsodium pkgs.util-linux pkgs.xz pkgs.systemd
      ]
      # The GL/Vulkan/Font stack (same packages /run/opengl-driver provides:
      # mesa + nvidia + nvidia-egl-external-platforms + nvidia-vaapi-driver,
      # plus the glvnd dispatchers, vulkan-loader and freetype). These are for
      # programs that run through nix-ld inside the pressure-vessel container
      # (osu-wine): their runtime LD_LIBRARY_PATH comes from
      # NIX_LD_LIBRARY_PATH, and pressure-vessel does NOT capture libs from the
      # host ld.so.cache into the container, so Wine's dlopen would otherwise
      # fail with "no driver could be loaded" / "cannot find the FreeType font
      # library".
      ++ config.hardware.graphics.extraPackages
      ++ [
        config.hardware.graphics.package
        pkgs.libglvnd
        pkgs.vulkan-loader
        pkgs.freetype
      ]
    );
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
      "x-gvfs-show"
    ];
  };
  environment.systemPackages = with pkgs; [
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

  # Bootloader — Limine: one clean menu for NixOS + Arch + Windows.
  # NixOS entries are generated per rebuild; Arch + Windows live in
  # extraEntries, which Limine's installer re-appends to /boot/limine/limine.conf.
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 5;
  boot.loader.limine.enable = true;
  boot.loader.limine.maxGenerations = 5;
  boot.loader.limine.extraConfig = ''
    remember_last_entry: yes
    interface_branding: kaan
    interface_branding_colour: 7EBAE4
  '';
  boot.loader.limine.extraEntries = ''
    /Arch Linux
        protocol: linux
        path: fslabel(archroot):/boot/vmlinuz-linux
        module_path: fslabel(archroot):/boot/initramfs-linux.img
        cmdline: root=LABEL=archroot rw

    /Windows
        protocol: efi_boot_entry
        entry: Windows Boot Manager
  '';

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

  # Bind-mount the NixOS system profile into the container. pressure-vessel
  # always mounts /nix, so nix-ld's loader paths (/nix/store, or the default
  # /run/current-system/sw/share/nix-ld/lib/ld.so) then resolve inside the
  # container too. Otherwise nix-ld panics with ENOENT there.
  environment.variables.PRESSURE_VESSEL_FILESYSTEMS_RW = "/run/current-system /nix";

  # pressure-vessel's capsule-capture-libs opens the ld.so.cache to figure out
  # which libraries to copy into the container. NixOS ships none, so generate
  # one at boot covering the GL/Vulkan driver dir and system libs. Provide it
  # at both locations the tool probes.
  #
  # Scan the NEW generation's sw/lib ($systemConfig is set at the top of the
  # activation script) instead of /run/current-system: the latter is only
  # re-pointed to the new generation at the END of activation, so scanning it
  # would cache the PREVIOUS generation's libraries (e.g. newly added
  # systemPackages would be missing from the container).
  system.activationScripts.ldsocache.text = ''
    mkdir -p /var/cache/ldconfig
    CACHE=/var/cache/ldconfig/ld.so.cache
    dirs="/run/opengl-driver/lib ''${systemConfig}/sw/lib"
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
