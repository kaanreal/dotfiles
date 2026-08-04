# shared

Dotfiles that look the same on every OS — they live once in `dots/` and get
linked from there:

- `dots/kitty`
- `dots/fastfetch`
- `dots/btop`
- `dots/micro`
- `dots/starship.toml`

`devices/shared/setup.sh` creates the `~/.config` symlinks. The linux/macos
setup scripts call it (or do the same inline).

OS-specific config stays with the OS:

- NixOS: everything is linked declaratively via
  `nix/home/kaan/dotfiles.nix` (out-of-store symlinks).
- Arch / macOS: the setup scripts link these shared entries and copy their
  OS-specific fish/starship configs from `devices/linux/setup/` and
  `devices/macos/setup/`.
