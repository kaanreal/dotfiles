{ pkgs, lib, caelestia-dots, caelestia-shell, ... }:

let
  dots = pkgs.applyPatches {
    name = "caelestia-dots";
    src = caelestia-dots;
    patches = [
      ../../patches/dots-execs.patch
      ../../patches/dots-kb-layout.patch
      ../../patches/dots-env.patch
      ../../patches/dots-fonts.patch
      ../../patches/dots-scheme.patch
    ];
  };

  shell = caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.with-cli;

  quickshell = (caelestia-shell.inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
    withX11 = false;
    withI3 = false;
  }).withModules [ pkgs.qt6.qtimageformats ];

  # `caelestia shell` execs `qs -c caelestia`; provide a `qs` on PATH that
  # replicates the env the shell package's own wrapper sets (QML plugin +
  # m3shapes import paths, extras libdir, xkb rules) before running quickshell.
  qs = pkgs.writeShellScriptBin "qs" ''
    export NIXPKGS_QT6_QML_IMPORT_PATH="${lib.concatStringsSep ":" [
      "${shell.plugin}/lib/qt-6/qml"
      "${shell.m3shapesModule}/lib/qt-6/qml"
    ]}''${NIXPKGS_QT6_QML_IMPORT_PATH:+:$NIXPKGS_QT6_QML_IMPORT_PATH}"
    export CAELESTIA_LIB_DIR="${shell.extras}/lib"
    export CAELESTIA_XKB_RULES_PATH="${pkgs.xkeyboard-config}/share/xkeyboard-config-2/rules/base.lst"
    exec ${quickshell}/bin/qs "$@"
  '';
in
{
  programs.caelestia = {
    enable = true;
    # The dots already spawn the shell via hyprland/execs.lua, so no systemd service.
    systemd = {
      enable = false;
      target = "graphical-session.target";
    };
    cli.enable = true;
  };

  home.packages = with pkgs; [
    # Shell + CLI runtime tools
    fuzzel
    grim
    slurp
    swappy
    wl-clipboard
    cliphist
    hyprpicker
    gammastep
    libnotify
    ydotool
    trash-cli
    pavucontrol
    xdg-user-dirs
    # Dotfile components
    fish
    starship
    foot
    fastfetch
    btop
    micro
    thunar
    eza
    zoxide
    direnv
    lazygit
    bat
    ripgrep
    jq
    # Random stuff
    opencode
    google-chrome
    tailscale
    github-desktop
    proton-vpn-cli
    spotify
    cava
    kitty
    gh
    gnome-software
    jamesdsp
    vscode
    # quickshell (qs) needed by the caelestia CLI to launch/IPC the shell
    qs
  ];

  home.file = {
    # Dotfiles, symlinked from the patched pinned input
    ".config/hypr" = {
      source = "${dots}/hypr";
      force = true;
    };
    ".config/fish".source = "${dots}/fish";
    ".config/foot".source = "${dots}/foot";
    ".config/fastfetch".source = "${dots}/fastfetch";
    ".config/btop".source = "${dots}/btop";
    ".config/micro".source = "${dots}/micro";
    ".config/Thunar" = {
      source = "${dots}/thunar";
      force = true;
    };
    ".config/starship.toml".source = "${dots}/starship.toml";

    # Make the shell QML discoverable by `qs -c caelestia` (quickshell looks
    # for <xdg-config>/quickshell/caelestia/shell.qml)
    ".config/quickshell/caelestia" = {
      source = "${shell}/share/caelestia-shell";
      force = true;
    };

    # User override files (editable, survive rebuilds)
    ".config/caelestia/hypr-vars.lua".text = ''
      return {
        kbLayout    = "de",
        cursorTheme = "Adwaita",
      }
    '';
    ".config/caelestia/hypr-user.lua".text = ''
      -- Caelestia user Hyprland config
	      hl.monitor({
          output   = "DP-1",
          mode     = "2560x1440@180",
          position = "auto",
          scale    = 1,
      })

    '';
    ".config/caelestia/user-config.fish".text = ''
      # Caelestia user fish config

      # Rebuild NixOS, then commit + push the config with a cozy message.
      function rebuild
          set -l repo $HOME/nix-config

          sudo nixos-rebuild switch --flake /etc/nixos
          or begin
              echo "💔 rebuild failed — nothing was committed"
              return 1
          end

          git -C $repo add -A

          if not git -C $repo diff --cached --quiet
              set -l emojis '🌸' '🌙' '☕' '🍃' '🧁' '🕯️' '🌷' '✨' '🫧'
              set -l emoji $emojis[(random 1 (count $emojis))]
              set -l msg "$emoji Rebuild "(date +%F\ %H:%M | string join ' ')
              set -l body (git -C $repo diff --cached --stat | string join \n)
              git -C $repo commit -m "$msg" -m "$body"

              set -l gen (readlink /nix/var/nix/profiles/system | grep -oE '[0-9]+' | tail -1)
              if test -n "$gen"
                  git -C $repo tag -a "nixos-$gen" -m "🌸 $msg"
              end

              if git -C $repo remote | grep -q .
                  git -C $repo push --follow-tags
              else
                  echo "🕊️ no git remote set — committed locally, skipped push"
              end
          else
              echo "🌸 nothing changed — config already up to date"
          end
      end
    '';
  };
}
