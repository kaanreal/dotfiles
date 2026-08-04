# Declarative packages. The desktop-critical CLI tools live here.
# Large GUI apps (chrome, spotify, steam, ...) are intentionally kept
# manageable by hand, so they stay in this list unchanged.
{ pkgs, home-manager, ... }:

{
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
    home-manager.packages.${pkgs.stdenv.hostPlatform.system}.home-manager
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
  ];
}
