# shared

Dotfiles that look the same on every OS — they live once in `dots/` and get
linked from there:

- `dots/fish` — the whole shell: prompt, colors, abbrs, shared commands
  (`save`, `dots-update`, `fastfetch`). macOS-specific bits are in
  `dots/fish/conf.d/darwin.fish` (auto-loaded only on macOS).
- `dots/kitty` — base config shared everywhere; per-OS tweaks via
  `include ${KITTY_OS}.conf` → `dots/kitty/macos.conf` / `dots/kitty/linux.conf`
- `dots/fastfetch`
- `dots/btop`
- `dots/micro`
- `dots/starship.toml`
- `dots/git/ignore_global` → `~/.gitignore_global`

`devices/shared/setup.sh` creates the `~/.config` symlinks. The linux/macos
setup scripts call it (or do the same inline).

NixOS links the same entries declaratively via
`nix/home/kaan/dotfiles.nix` (out-of-store symlinks).

OS-specific config stays with the OS:

- NixOS: system + home packages (`rebuild`, `update`, `cleanup`) live in
  `dots/caelestia/user-config.fish`, sourced only when Caelestia is present.
- macOS: `devices/macos/setup.sh` adds the Homebrew helpers and macOS
  defaults on top.
