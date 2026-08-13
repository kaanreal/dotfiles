# 📁dotfiles.

One repo for every machine I own.

## Devices

| OS          | Where               | Bootloader               | Desktop               | State                  |
| ----------- | ------------------- | ------------------------ | --------------------- | ---------------------- |
| **NixOS**   | NVMe 2 (~400 GB)    | **Limine** (shared ESP)  | Caelestia on Hyprland | learning purposes      |
| **Arch**    | NVMe 2 (`archroot`) | Limine entry (`fslabel`) | Hyprland and Xfwm4    | daily driver           |
| **Windows** | NVMe 1              | Limine entry (chainload) | Explorer              | forced daily driver... |
| **macOS**   | in my bag?          | Apple                    | Quartz                | everyday tasks         |

## Layout

```
~/dotfiles
├── flake.nix                 # NixOS + home-manager entry point
├── hosts/nixos-desktop/      # NixOS host, hardware, boot, GPU, and nh
├── nix/
│   ├── modules/              # system modules
│   └── home/kaan/            # Home Manager configuration
├── dots/                     # vendored Caelestia dots plus local overrides
├── devices/
│   ├── shared/               # shared dotfiles
│   └── macos/                # independent macOS dots
└── scripts/                  # install, update, backup, and helper scripts
```

NixOS uses Home Manager out-of-store symlinks into `dots/`, so most dotfile
changes take effect after restarting or reloading the relevant application.
macOS links its independent copies from `devices/macos/dots/`.

## 🌊Caelestia upstream

`dots/` is a vendored copy of [caelestia-dots/caelestia](https://github.com/caelestia-dots/caelestia),
with my patches and overrides baked on top. The original stays reachable
as the `caelestia-upstream` remote, so fixes keep flowing in:

| Task                            | Command                                               |
| ------------------------------- | ----------------------------------------------------- |
| Pull upstream dots into `dots/` | `dots-update` (fish) or `scripts/update-caelestia.sh` |
| Resolve a conflicted dotfile    | fix it in `dots/…`, then `save`                       |

`dots-update` fetches upstream and runs `git subtree pull`. It requires a clean
working tree and stops for manual resolution if a merge conflicts.

## Shortcuts

| Task                     | Command                           |
| ------------------------ | --------------------------------- |
| Rebuild NixOS (+ home)   | `rebuild` (fish) → `nh os switch` |
| Update nixpkgs + rebuild | `update` (fish)                   |
| Pull upstream dotfiles   | `dots-update` (fish)              |
| Commit + push everything | `save` (fish)                     |
| Free old generations     | `cleanup` (fish) → `nh clean all` |
| Backup the repo          | `scripts/backup.sh`               |

`save` stages the whole repository, creates a timestamped snapshot commit, and
pushes it to `origin`. It exits without committing when nothing changed.
Commit subjects use a random cozy emoji
followed by the local date and time, for example `🧸 2026-08-04 21:30:12`.##

---

<div align="center">

<img width=300 src="https://github.com/kaanreal/Kaanreal/raw/main/assets/main.gif"/>

## Built by me , bye.

<a href="https://buymeacoffee.com/kaandev">
<img src="https://img.shields.io/badge/☕%20buy%20me%20a%20coffee-FFE082?style=for-the-badge&logo=buymeacoffee&logoColor=black"/>
