# 🏡 cozy-home

One cozy repo for every machine I own — NixOS system config, Home Manager,
my dotfiles, and the Caelestia shell customizations, all in plain git files.

> “Everything in one place. Everything rebuildable. Everything *mine*.”

---

## 🗺️ The machines

| OS | Where | Bootloader | Desktop | State |
| --- | --- | --- | --- | --- |
| **NixOS** | Crucial SSD (shrunk to ~400G) | **Limine** (shared ESP) | Caelestia shell on Hyprland | ✅ daily driver |
| **Arch** | Crucial SSD (~500G, label `archroot`) | Limine entry (`fslabel`) | minimal Hyprland (optional) | 🚧 install via `scripts/install-arch.sh` |
| **Windows** | Samsung 990 PRO | Limine entry (chainload) | — | ✅ installed |
| **macOS** | Mac.fritz.box (Apple Silicon) | — | — | ✅ setup via `devices/macos/setup.sh` |

## 🗂️ Layout

```
~/cozy-home
├── flake.nix                 # NixOS + home-manager entry point
├── hosts/                    # per-machine host configs
│   ├── nixos-desktop/        #   ✅ NixOS: hardware + boot + GPU + nh
│   ├── arch-desktop/         #   (no flake yet — plain Arch, see devices/linux)
│   └── macbook/              #   (no flake yet — see devices/macos)
├── nix/
│   ├── modules/              # system modules: base, desktop, gpu, packages
│   └── home/kaan/            # user config: apps, caelestia, dotfiles, mimeapps
├── dots/                     # the dotfiles (vendored caelestia + kaan overrides)
│   ├── caelestia/            #   kaan: hypr-vars.lua, hypr-user.lua, cli.json…
│   ├── fish/                 #   shared shell: config.fish, conf.d/, functions/
│   ├── git/                  #   git identity + global ignore
│   ├── hypr/ foot/ kitty/ fastfetch/ btop/ micro/ thunar/ starship.toml
│   └── (upstream history via the caelestia-upstream remote)
├── devices/                  # non-NixOS setups
│   ├── shared/               #   links the OS-agnostic dots (fish, kitty, fastfetch…)
│   ├── linux/                #   Arch: install notes + setup.sh + setup/
│   └── macos/                #   macOS: setup.sh + README (config lives in dots/)
└── scripts/                  # install-nixos, install-arch, install-macos,
                              # update-caelestia, backup
```

On NixOS, `~/.config/*` are **out-of-store symlinks** into `~/cozy-home/dots`
(see `nix/home/kaan/dotfiles.nix`). macOS links the exact same entries with
`devices/shared/setup.sh`. Editing a dotfile needs **no rebuild** — restart
the app or shell and it's live.

## 🌊 Caelestia upstream

`dots/` is a vendored copy of [caelestia-dots/caelestia](https://github.com/caelestia-dots/caelestia),
with kaan's patches and overrides baked on top. The original stays reachable
as the `caelestia-upstream` remote, so fixes keep flowing in:

| Task | Command |
| --- | --- |
| Pull upstream dots into `dots/` | `dots-update` (fish) or `scripts/update-caelestia.sh` |
| Resolve a conflicted dotfile | fix it in `dots/…`, then `save` |

`dots-update` fetches upstream and does a `git subtree pull` — it refuses to
run on an uncommitted tree, never force-resets, and never silently overwrites
your local edits. On a conflict it stops and shows you the files.

## 🚀 Daily life

| Task | Command |
| --- | --- |
| Rebuild NixOS (+ home) | `rebuild` (fish) → `nh os switch` |
| Update nixpkgs + rebuild | `update` (fish) |
| Pull upstream dotfiles | `dots-update` (fish) |
| Commit + push everything | `save` (fish) |
| Free old generations | `cleanup` (fish) → `nh clean all` |
| Backup the repo | `scripts/backup.sh` |
| Edit a keybind / app config | edit `dots/…` directly, reload Hyprland (`hyprctl reload`) |

`save` commits a full snapshot of the repo (system config **and** dots
together — one place, one history) and pushes it to `origin`. It skips the
commit and push when nothing changed. Commit subjects use a random cozy emoji
followed by the local date and time, for example `🧸 2026-08-04 21:30:12`.
No version counters or tags — every commit is a checkpoint.

## 🎨 Where to change what

| I want to... | Go to |
| --- | --- |
| add / remove an app | `home.packages` in `nix/home/kaan/apps.nix` |
| change keybinds, gaps, blur | `dots/caelestia/hypr-vars.lua` (live) |
| add window rules / autostart | `dots/caelestia/hypr-user.lua` (live) |
| change shell settings (apps, transparency…) | `dots/caelestia/shell.json` (live) |
| change special-workspace apps | `dots/caelestia/cli.json` (live) |
| change fish functions (`rebuild`, `save`, …) | Nix-only: `dots/caelestia/user-config.fish` (live) · shared (`save`, `dots-update`): `dots/fish/functions/` (live) |
| change shell colors / brew aliases on macOS | `dots/fish/conf.d/theme.fish`, `dots/fish/conf.d/darwin.fish` (live) |
| change the boot menu | `boot.loader.limine` in `hosts/nixos-desktop/default.nix` |
| change NixOS system packages | `nix/modules/packages.nix` |
| edit kitty / fastfetch for all OSes | `dots/kitty`, `dots/fastfetch` |
| tweak kitty just on macOS / Linux | `dots/kitty/macos.conf`, `dots/kitty/linux.conf` (live) |
| set up Arch | `devices/linux/setup.sh` + `devices/linux/README.md` |
| set up macOS | `devices/macos/setup.sh` + `devices/macos/README.md` |

## 🖼️ Screenshots

*coming soon — Caelestia shell, Hyprland, the works.*

## 🤍 Built with love, Nix, Arch, and way too much caffeine
