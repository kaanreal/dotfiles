# Personal dotfiles: plain editable files in ~/dotfiles (a git fork of
# caelestia-dots/caelestia with kaan's overrides). These out-of-store links
# point straight at the live directory, so editing a keybind or app config
# is immediate — no rebuild, no /nix/store copies.
#
#   ~/.config/hypr        -> ~/dotfiles/hypr        (restart shell to apply)
#   ~/.config/caelestia   -> ~/dotfiles/caelestia   (user overrides, cli.json)
#   ~/.config/fish        -> ~/dotfiles/fish
#   ~/.config/kitty       -> ~/dotfiles/kitty       (live)
#   ...
{ config, ... }:

let
  dots = "${config.home.homeDirectory}/dotfiles";
in
{
  home.file = {
    ".config/hypr".source = config.lib.file.mkOutOfStoreSymlink "${dots}/hypr";
    ".config/caelestia".source = config.lib.file.mkOutOfStoreSymlink "${dots}/caelestia";
    ".config/fish".source = config.lib.file.mkOutOfStoreSymlink "${dots}/fish";
    ".config/foot".source = config.lib.file.mkOutOfStoreSymlink "${dots}/foot";
    ".config/btop".source = config.lib.file.mkOutOfStoreSymlink "${dots}/btop";
    ".config/micro".source = config.lib.file.mkOutOfStoreSymlink "${dots}/micro";
    ".config/Thunar".source = config.lib.file.mkOutOfStoreSymlink "${dots}/Thunar";
    ".config/starship.toml".source = config.lib.file.mkOutOfStoreSymlink "${dots}/starship.toml";
    ".config/kitty".source = config.lib.file.mkOutOfStoreSymlink "${dots}/kitty";
    ".config/fastfetch".source = config.lib.file.mkOutOfStoreSymlink "${dots}/fastfetch";
  };
}
