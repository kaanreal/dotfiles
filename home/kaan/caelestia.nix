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
    bibata-cursors
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
    vim
    neovim
    vimPlugins.LazyVim
    vesktop
    zenity
    unzip
    gearlever
    steam
    # quickshell (qs) needed by the caelestia CLI to launch/IPC the shell
    qs
  ];

  # System-wide default apps (what opens files / links).
  # home-manager owns ~/.config/mimeapps.list; force overwrites the files
  # GNOME/chrome already created.
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Code / text -> VS Code
      "text/plain" = [ "code.desktop" ];
      "application/json" = [ "code.desktop" ];
      "text/markdown" = [ "code.desktop" ];
      "text/x-python" = [ "code.desktop" ];
      "text/x-shellscript" = [ "code.desktop" ];
      "text/javascript" = [ "code.desktop" ];
      "text/xml" = [ "code.desktop" ];
      "text/x-csrc" = [ "code.desktop" ];
      "text/x-c++src" = [ "code.desktop" ];
      # Folders -> Nautilus
      "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
      # Web -> Chrome
      "text/html" = [ "google-chrome.desktop" ];
      "x-scheme-handler/http" = [ "google-chrome.desktop" ];
      "x-scheme-handler/https" = [ "google-chrome.desktop" ];
      "x-scheme-handler/about" = [ "google-chrome.desktop" ];
      "x-scheme-handler/unknown" = [ "google-chrome.desktop" ];
    };
  };
  xdg.configFile."mimeapps.list".force = true;
  xdg.dataFile."applications/mimeapps.list".force = true;

    # Kitty config
     xdg.configFile."kitty".source = ./kitty;

    # Fastfetch config
     xdg.configFile."fastfetch".source = ./fastfetch;


  home.file = {
    # Dotfiles, symlinked from the patched pinned input
    ".config/hypr" = {
      source = "${dots}/hypr";
      force = true;
    };
    ".config/fish".source = "${dots}/fish";
    ".config/foot".source = "${dots}/foot";
    # ".config/fastfetch".source = "${dots}/fastfetch";
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
        kbLayout     = "de",
        cursorTheme  = "Bibata-Modern-Classic",
        fileExplorer = "nautilus",
        terminal     = "kitty",
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

      -- Mouse: no acceleration (Hyprland >= 0.55: accel_speed was removed,
      -- force_no_accel is the replacement)
      hl.config({
          input = {
              force_no_accel = true,
          },
      })

      -- Autostart
      hl.on("hyprland.start", function()
          hl.exec_cmd("jamesdsp --tray --watch")
      end)

    '';
    ".config/caelestia/user-config.fish".text = ''
      # Caelestia user fish config

      # User-installed scripts (e.g. osu-wine from osu-winello).
      # set (not fish_add_path): the dots' ~/.config/fish is a read-only nix
      # store symlink, so universal variables cannot be written.
      set -gx PATH $HOME/.local/bin $PATH

      # Force the container-correct nix-ld env. The login session (started
      # before the fix) inherits NIX_LD=/run/current-system/... from an old
      # /etc/set-environment; inside the pressure-vessel container that path
      # does not exist -> nix-ld ENOENT panic. /nix/store paths work on the
      # host AND inside the container (which only mounts /nix).
      set -gx NIX_LD /nix/store/w59civhx8gfi5w00qz6xrv951s13kf7g-nix-ld-libraries/share/nix-ld/lib/ld.so
      set -gx NIX_LD_LIBRARY_PATH /nix/store/w59civhx8gfi5w00qz6xrv951s13kf7g-nix-ld-libraries/share/nix-ld/lib

      # Rebuild NixOS, bump the version counter, then commit + tag + push.
      # The version lives in .version, so every successful rebuild always
      # moves to the next number and cleanup can never reset it.
      function rebuild
          set -l repo $HOME/nix-config
          set -l verfile $repo/.version

          sudo nixos-rebuild switch --flake /etc/nixos
          or begin
              echo "💔 rebuild failed — nothing was committed"
              return 1
          end

          set -l ver 0
          if test -f $verfile
              set ver (string trim (cat $verfile))
          end
          set -l next (math "$ver + 1")
          echo $next > $verfile

          git -C $repo add -A

          set -l emojis '🌸' '🌙' '☕' '🍃' '🧁' '🕯️' '🌷' '✨' '🫧'
          set -l emoji $emojis[(random 1 (count $emojis))]
          set -l msg "$emoji Rebuild "(date +%F\ %H:%M | string join ' ')
          set -l body (git -C $repo diff --cached --stat | string join \n)
          git -C $repo commit -m "$msg" -m "$body"

          git -C $repo tag -a "nixos-$next" -m "🌱 nixos-$next"
          echo "🌱 tagged nixos-$next"

          if git -C $repo remote | grep -q .
              git -C $repo push --follow-tags
              or echo "⚠️ committed + tagged locally, but push failed"
          else
              echo "🕊️ no git remote set — committed locally, skipped push"
          end
      end

      # Delete old Nix generations and old local tags. GitHub keeps every tag
      # forever; locally we keep only the newest (nixos-$ver). The version
      # counter is untouched, so the next rebuild continues from there.
      function cleanup
          set -l repo $HOME/nix-config
          set -l verfile $repo/.version

          sudo nix-collect-garbage -d

          set -l ver 0
          if test -f $verfile
              set ver (string trim (cat $verfile))
          end
          set -l keep "nixos-$ver"
          set -l tags (git -C $repo tag -l 'nixos-*' | string match -v $keep)
          if test -n "$tags"
              git -C $repo tag -d $tags
          end
          echo "🧹 cleaned up — GitHub keeps all tags, local keeps nixos-$ver, next rebuild is nixos-"(math "$ver + 1")
      end

      # Override the dots' CAELESTIA ASCII banner greeting: fish skips
      # autoloading fish_greeting.fish because we define it here first.
      function fish_greeting
          command -v fastfetch &> /dev/null && fastfetch
      end

      # Adaptive fastfetch: shrink the logo so it always fits the window.
      # function <name> shadows the real binary, `command fastfetch` bypasses it.
      function fastfetch
          set -l cols 80
          if command stty size >/dev/null 2>&1
              set cols (string split ' ' (stty size))[2]
          end
          set -l w 45
          if test $cols -lt 90
              set w 32
          end
          if test $cols -lt 72
              set w 24
          end
          if test $cols -lt 55
              set w 16
          end
          command fastfetch --logo-width $w $argv
      end
    '';
  };
}
