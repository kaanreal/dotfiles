# shared

Dotfiles that look the same on every **Linux** machine (NixOS, Arch) — they
live once in `dots/` and get linked from there:

- `dots/fish` — the whole shell: prompt, colors, abbrs, shared commands
  (`save`, `dots-update`, `fastfetch`)
- `dots/kitty`
- `dots/fastfetch`
- `dots/btop`
- `dots/micro`
- `dots/starship.toml`
- `dots/git/ignore_global` → `~/.gitignore_global`

`devices/shared/setup.sh` creates the `~/.config` symlinks for non-Nix
Linux machines. NixOS links the same entries declaratively via
`nix/home/kaan/dotfiles.nix` (out-of-store symlinks).

macOS is **not** shared — it keeps its own independent copies in
`devices/macos/dots/` (see `devices/macos/README.md`).
