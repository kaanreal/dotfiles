# macOS

The second (non-Nix) machine in the cozy-home setup. There is no Nix here —
everything is plain git files in `~/cozy-home` linked from `dots/`, exactly
like on NixOS.

The old `devices/macos/setup/fish/` approach is gone: **fish lives centrally
in `dots/fish/`** and is symlinked to `~/.config/fish` like every other shared
app. macOS-specific shell bits are auto-loaded from
`dots/fish/conf.d/darwin.fish` (brew env, brew abbrs, `clearfetch`).

## How it works

```
~/.config/fish        -> ~/cozy-home/dots/fish            (prompt, colors, abbrs,
                                                           save / dots-update / fastfetch)
~/.config/kitty       -> ~/cozy-home/dots/kitty
~/.config/fastfetch   -> ~/cozy-home/dots/fastfetch
~/.config/btop        -> ~/cozy-home/dots/btop
~/.config/micro       -> ~/cozy-home/dots/micro
~/.config/starship.toml -> ~/cozy-home/dots/starship.toml
~/.gitconfig          -> ~/cozy-home/dots/git/config
~/.gitignore_global   -> ~/cozy-home/dots/git/ignore_global
```

Editing a dotfile needs no re-run — restart the app (or open a new shell)
and it's live.

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

Same as NixOS for the shared, OS-agnostic ones:

| Command | What it does |
| --- | --- |
| `save` | commit + push a snapshot of `~/cozy-home` (shared with NixOS) |
| `dots-update` | pull upstream Caelestia dots (shared with NixOS) |
| `dots` | `cd ~/cozy-home` |
| `up` / `in` / `un` / `se` | brew upgrade+cleanup / install / uninstall / search |

The Nix-only commands (`rebuild`, `update`, `cleanup`) intentionally don't
exist here — they're defined in `dots/caelestia/user-config.fish`, which is
only sourced on machines with Caelestia.

## Where to change what

| I want to... | Go to |
| --- | --- |
| change shell colors / abbrs / prompt | `dots/fish` (live) |
| change brew aliases / macOS shell bits | `dots/fish/conf.d/darwin.fish` (live) |
| change kitty look (font, opacity, cmd keys) | `dots/kitty/macos.conf` (live, macOS-only) |
| edit kitty / fastfetch / btop / micro | `dots/...` (live) |
| change git identity / excludes | `dots/git/config` (live) |
| add a brew package | `devices/macos/setup.sh` |

`dots/kitty/kitty.conf` ends with `include ${KITTY_OS}.conf`, so `macos.conf`
is loaded only on macOS and `linux.conf` only on Linux — kitty tweaks never
bleed between machines.
