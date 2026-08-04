# 🏡 kaan's cozy multi-OS home

One repo, three machines — **NixOS**, **Arch Linux**, and a **Mac** (planned).
Shared dotfiles are versioned once and reused everywhere. Everything is
backed up to GitHub with a single command per OS.

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
.
├── flake.nix                  # entry point + pinned inputs
├── nixos/                     # NixOS + home-manager
│   ├── hosts/nixos/           # this machine (boot, GPU, networking)
│   ├── home/kaan/             # user config: apps, dots, overrides
│   ├── modules/               # base, gpu, hyprland, caelestia
│   └── patches/               # dots patches (execs, env, kb, fonts, scheme)
├── arch/                      # Arch Linux
│   ├── install.sh             # run from the Arch ISO (disk surgery + install)
│   ├── setup.sh               # dotfiles + optional Hyprland desktop
│   ├── setup/                 # Arch-specific fish, starship, hyprland, waybar
│   └── README.md              # step-by-step install guide
├── mac/                       # macOS (planned)
│   ├── bootstrap.sh           # Homebrew + dots clone
│   ├── setup.sh               # fish, starship, Dock/defaults
│   └── README.md
└── dotfiles/                  # shared across all OSes
    ├── kitty/                 # kitty.conf
    └── fastfetch/             # config.jsonc + logos
```

## 🚀 Daily life

| Task | Command |
| --- | --- |
| Rebuild NixOS | `rebuild` (fish) |
| Apply home-manager only | `hm` (fish) |
| Free old generations | `cleanup` (fish) |
| Backup everything | `nixpush` (NixOS) · `dotpush` (Arch/macOS) |

`nixpush` / `dotpush` are the same idea per OS: commit a full snapshot of
this repo and push to GitHub. No version counters or tags — every commit
is a checkpoint, run them as often as you like.

## 🎨 Where to change what

| I want to... | Go to |
| --- | --- |
| add / remove an app (NixOS) | `home.packages` in `nixos/home/kaan/caelestia.nix` |
| change keybinds, gaps, blur | `hypr-vars.lua` in `nixos/home/kaan/caelestia.nix` |
| add window rules | `hypr-user.lua` in `nixos/home/kaan/caelestia.nix` |
| change the boot menu | `boot.loader.limine` in `nixos/hosts/nixos/default.nix` |
| edit kitty / fastfetch for all OSes | `dotfiles/kitty`, `dotfiles/fastfetch` |
| change Arch setup | `arch/setup/` + `arch/README.md` |
| fix something in the upstream dots | add a patch in `nixos/patches/` |

## 🤍 Built with love, Nix, Arch, and way too much caffeine
