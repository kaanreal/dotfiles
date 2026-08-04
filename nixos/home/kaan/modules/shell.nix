# Fish-related integration and shell packages.
# Fish itself is fully config-file driven (see modules/dotfiles.nix:
# ~/.config/fish -> ~/dotfiles/fish, and user-config.fish -> ~/dotfiles).
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    fish
    starship
    foot
    eza
    zoxide
    direnv
    lazygit
    bat
    ripgrep
    jq
  ];
}
