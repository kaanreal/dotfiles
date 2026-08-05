# Caelestia shell package, Quickshell wrapper, and runtime dependencies.
# Only the package is pinned via Nix here; the config lives in
# dots/ (see nix/home/kaan/dotfiles.nix) so it stays editable.
{
  pkgs,
  lib,
  caelestia-shell,
  ...
}:

let
  baseShell = caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.with-cli;
  shell = baseShell.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./caelestia-local-covers.patch ];
  });

  localCover = pkgs.writeShellApplication {
    name = "caelestia-local-cover";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.ffmpeg
      pkgs.findutils
      pkgs.gnused
    ];
    text = builtins.readFile ../../../scripts/caelestia-local-cover.sh;
  };

  quickshell =
    (caelestia-shell.inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
      withX11 = false;
      withI3 = false;
    }).withModules
      [ pkgs.qt6.qtimageformats ];

  # `caelestia shell` execs `qs -c caelestia`; provide a `qs` on PATH that
  # replicates the env the shell package's own wrapper sets (QML plugin +
  # m3shapes import paths, extras libdir, xkb rules) before running quickshell.
  qs = pkgs.writeShellScriptBin "qs" ''
    export NIXPKGS_QT6_QML_IMPORT_PATH="${
      lib.concatStringsSep ":" [
        "${shell.plugin}/lib/qt-6/qml"
        "${shell.m3shapesModule}/lib/qt-6/qml"
      ]
    }''${NIXPKGS_QT6_QML_IMPORT_PATH:+:$NIXPKGS_QT6_QML_IMPORT_PATH}"
    export CAELESTIA_LIB_DIR="${shell.extras}/lib"
    export CAELESTIA_XKB_RULES_PATH="${pkgs.xkeyboard-config}/share/xkeyboard-config-2/rules/base.lst"
    exec ${quickshell}/bin/qs "$@"
  '';
in
{
  imports = [
    caelestia-shell.homeManagerModules.default
  ];

  programs.caelestia = {
    enable = true;
    # The dots already spawn the shell via hyprland/execs.lua, so no systemd service.
    systemd = {
      enable = false;
      target = "graphical-session.target";
    };
    cli.enable = true;
  };

  home.packages = [
    qs
    localCover
  ];

  home.file = {
    # Make the shell QML discoverable by `qs -c caelestia` (quickshell looks
    # for <xdg-config>/quickshell/caelestia/shell.qml)
    ".config/quickshell/caelestia" = {
      source = "${shell}/share/caelestia-shell";
      force = true;
    };
  };
}
