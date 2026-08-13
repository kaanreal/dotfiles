# macOS

The second (non-Nix) machine in the cozy-home setup. There is no Nix here —
everything is plain git files in `~/cozy-home`. The Mac is **fully
independent**: its dotfiles live in `devices/macos/dots/` as its own copies,
not shared with the NixOS `dots/`. `save` snapshots the whole repo, so every
time you save, your Mac dotfiles are checkpointed from that dir.

## How it works

```
~/.config/fish          -> ~/cozy-home/devices/macos/dots/fish
~/.config/kitty         -> ~/cozy-home/devices/macos/dots/kitty
~/.config/fastfetch     -> ~/cozy-home/devices/macos/dots/fastfetch
~/.config/btop          -> ~/cozy-home/devices/macos/dots/btop
~/.config/micro         -> ~/cozy-home/devices/macos/dots/micro
~/.config/starship.toml -> ~/cozy-home/devices/macos/dots/starship.toml
~/.gitconfig            -> ~/cozy-home/devices/macos/dots/git/gitconfig
~/.gitignore_global     -> ~/cozy-home/devices/macos/dots/git/gitignore_global
```

Because the links point at the repo, editing a dotfile — either in
`~/.config/...` or directly in `devices/macos/dots/...` — is the same file.
`save` commits everything. Restart the app (or open a new shell) and it's
live.

## Setup

```sh
# 1. Command Line Tools
xcode-select --install

# 2. Clone the repo (if not already here)
git clone https://github.com/kaanreal/cozy-home.git ~/cozy-home

# 3. Bootstrap (Homebrew + repo + links), then the macOS specifics:
curl -fsSL https://raw.githubusercontent.com/kaanreal/cozy-home/main/scripts/install-macos.sh | bash
~/cozy-home/devices/macos/setup.sh --defaults
```

`setup.sh` is idempotent — re-run it after cloning on a new Mac, or to
refresh the symlinks.

## Commands

The `save` / `dots-update` / `dots` commands exist here too, defined in
`devices/macos/dots/fish/functions/`:

| Command                   | What it does                                                      |
| ------------------------- | ----------------------------------------------------------------- |
| `save`                    | commit + push a snapshot of `~/cozy-home` (Mac dotfiles included) |
| `dots-update`             | pull upstream Caelestia dots                                      |
| `dots`                    | `cd ~/cozy-home`                                                  |
| `up` / `in` / `un` / `se` | brew upgrade+cleanup / install / uninstall / search               |

The Nix-only commands (`rebuild`, `update`, `cleanup`) intentionally don't
exist here — they're defined in `dots/caelestia/user-config.fish`, which is
only sourced on machines with Caelestia.

## Where to change what

| I want to...                                | Go to                                               |
| ------------------------------------------- | --------------------------------------------------- |
| change shell colors / abbrs / prompt        | `devices/macos/dots/fish` (live)                    |
| change brew aliases / macOS shell bits      | `devices/macos/dots/fish/conf.d/darwin.fish` (live) |
| change kitty look (font, opacity, cmd keys) | `devices/macos/dots/kitty/kitty.conf` (live)        |
| change fastfetch (logo / modules)           | `devices/macos/dots/fastfetch/config.jsonc` (live)  |
| edit btop / micro / starship                | `devices/macos/dots/...` (live)                     |
| change git identity / excludes              | `devices/macos/dots/git/gitconfig` (live)           |
| add a brew package                          | `devices/macos/setup.sh`                            |
