# 🏡 kaan's cozy multi-OS home

One repo for the system config, one repo for the dotfiles — **NixOS**, **Arch
Linux**, and a **Mac** (planned). The dotfiles are a git fork of
caelestia-dots/caelestia, so upstream fixes keep flowing in while everything
stays editable in plain files. Both repos are backed up to GitHub.

> “Everything in one place. Everything rebuildable. Everything *mine*.”

---

## 🗺️ The machines

| OS | Where | Bootloader | Desktop | State |
| --- | --- | --- | --- | --- |
| **NixOS** | Crucial SSD (shrunk to ~400G) | **Limine** (shared ESP) | Caelestia shell on Hyprland | ✅ daily driver |
| **Arch** | Crucial SSD (~500G, label `archroot`) | Limine entry (`fslabel`) | minimal Hyprland (optional) | 🚧 install via `arch/install.sh` |
| **Windows** | Samsung 990 PRO | Limine entry (chainload) | — | ✅ installed |
| **macOS** | — | — | — | 📋 `mac/` bootstrap ready |

Limine lives on the shared ESP and is managed entirely by NixOS. Each
rebuild regenerates its entries for NixOS, Arch (`/Arch Linux`) and
Windows (`/Windows`) — see `nixos/hosts/nixos/default.nix`.

## 🗂️ Layout

```
~/nix-config                 # this repo: system + user config (declarative)
├── flake.nix                # entry point + pinned inputs
├── nixos/
│   ├── hosts/nixos/         # this machine (boot, GPU, networking, nh)
│   ├── home/kaan/           # user config, split into modules/
│   │   └── modules/         # shell.nix (caelestia), dotfiles.nix,
│   │                        # apps.nix, mimeapps.nix
│   └── modules/             # base, gpu, hyprland, caelestia
├── arch/                    # Arch Linux (install.sh, setup.sh, setup/)
└── mac/                     # macOS (planned: bootstrap.sh, setup.sh)

~/dotfiles                   # git fork of caelestia-dots/caelestia (editable)
├── hypr/ fish/ foot/ btop/ micro/ Thunar/ starship.toml   # the dots
├── caelestia/               # kaan's overrides: hypr-vars.lua, hypr-user.lua,
│                            # user-config.fish, cli.json, shell.json
├── kitty/  fastfetch/       # shared with Arch + macOS
└── (upstream remote -> caelestia-dots/caelestia)
```

`~/.config/*` are symlinks into `~/dotfiles` (out-of-store links, set in
`nixos/home/kaan/modules/dotfiles.nix`). Editing a dotfile needs **no
rebuild** — restart the app/shell and it's live.

## 🚀 Daily life

| Task | Command |
| --- | --- |
| Rebuild NixOS (+ home) | `rebuild` (fish) → `nh os switch` |
| Update nixpkgs + rebuild | `update` (fish) |
| Free old generations | `cleanup` (fish) → `nh clean all` |
| Commit + push both repos | `save` (fish) |
| Pull upstream dotfiles changes | `cd ~/dotfiles && git fetch upstream && git merge upstream/main` |
| Edit a keybind / app config | edit `~/dotfiles/...` directly, restart the app or shell |

`save` commits a full snapshot of `~/nix-config` **and** `~/dotfiles` and
pushes both to GitHub. No version counters or tags — every commit is a
checkpoint, run it as often as you like.

## 🎨 Where to change what

| I want to... | Go to |
| --- | --- |
| add / remove an app (NixOS) | `home.packages` in `nixos/home/kaan/modules/apps.nix` |
| change keybinds, gaps, blur | `~/dotfiles/caelestia/hypr-vars.lua` (live) |
| add window rules / autostart | `~/dotfiles/caelestia/hypr-user.lua` (live) |
| change shell settings (apps, transparency…) | `~/dotfiles/caelestia/shell.json` (live) |
| change special-workspace apps | `~/dotfiles/caelestia/cli.json` (live) |
| change fish functions (`rebuild`, `save`, …) | `~/dotfiles/caelestia/user-config.fish` (live) |
| change the boot menu | `boot.loader.limine` in `nixos/hosts/nixos/default.nix` |
| edit kitty / fastfetch for all OSes | `~/dotfiles/kitty`, `~/dotfiles/fastfetch` |
| change Arch setup | `arch/setup/` + `arch/README.md` |
| merge upstream dotfiles | `cd ~/dotfiles && git fetch upstream && git merge upstream/main` |

## 🤍 Built with love, Nix, Arch, and way too much caffeine
