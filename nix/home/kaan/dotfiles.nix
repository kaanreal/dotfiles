# Personal dotfiles: plain writable Git files in this repo (~/dotfiles/dots).
# The dots are a vendored copy of caelestia-dots/caelestia with kaan's
# overrides on top. These out-of-store links point straight at the live
# directory, so editing a keybind or desktop setting is immediate — no
# rebuild, no /nix/store copies.
#
#   ~/.config/hypr      -> ~/dotfiles/dots/hypr      (restart shell to apply)
#   ~/.config/caelestia -> ~/dotfiles/dots/caelestia (user overrides, cli.json)
#   ~/.config/fish      -> ~/dotfiles/dots/fish
#   ...
{ config, ... }:

let
  dotfiles = "${config.home.homeDirectory}/dotfiles/dots";
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  xdg.configFile = {
    "hypr" = {
      source = link "${dotfiles}/hypr";
      force = true;
    };

    "caelestia" = {
      source = link "${dotfiles}/caelestia";
      force = true;
    };

    "fish" = {
      source = link "${dotfiles}/fish";
      force = true;
    };

    "foot" = {
      source = link "${dotfiles}/foot";
      force = true;
    };

    "kitty" = {
      source = link "${dotfiles}/kitty";
      force = true;
    };

    "fastfetch" = {
      source = link "${dotfiles}/fastfetch";
      force = true;
    };

    "btop" = {
      source = link "${dotfiles}/btop";
      force = true;
    };

    "micro" = {
      source = link "${dotfiles}/micro";
      force = true;
    };

    # The repo dir is lowercase "thunar" but Thunar reads ~/.config/Thunar.
    "Thunar" = {
      source = link "${dotfiles}/thunar";
      force = true;
    };

    "starship.toml" = {
      source = link "${dotfiles}/starship.toml";
      force = true;
    };
  };
}
