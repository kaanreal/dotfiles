# ❄️ kaan's cozy NixOS home

A hand-rolled, fully reproducible NixOS + home-manager setup running the
**Caelestia shell** on **Hyprland**.

> “Everything in one place. Everything rebuildable. Everything *mine*.”

---

## ✨ What lives here

- 🏠 **NixOS system config** — boot, GPU, networking, GDM
- 🐚 **Caelestia shell** on Hyprland — patched, tuned, and auto-started
- 🧩 **home-manager** — apps, dotfiles, and user overrides
- 🩹 **5 hand-written patches** fixing the upstream dots for this machine

## 🗂️ Layout

```
.
├── flake.nix                  # entry point + pinned inputs
├── flake.lock                 # 🔒 the reproducibility contract
├── modules/                   # system-level building blocks
│   ├── base.nix               # fonts, bluetooth, base packages
│   ├── gpu.nix                # NVIDIA RTX 3050 (open modules)
│   ├── hyprland.nix           # Hyprland + Qt theming
│   └── caelestia.nix          # geoclue, polkit helper
├── hosts/nixos/               # this machine's system config
│   ├── default.nix
│   └── hardware-configuration.nix
├── home/kaan/                 # user-space config
│   ├── default.nix
│   └── caelestia.nix          # dots, patches, apps, user overrides
└── patches/                   # dots patches (execs, env, kb, fonts, scheme)
```

## 🚀 Quickstart

| Task | Command |
| --- | --- |
| 🛠️ **rebuild** | `rebuild` (fish) — switch + commit + tag + push |
| ⬆️ **update** | `nix flake update` then `rebuild` |
| ↩️ **rollback** | `sudo nixos-rebuild --rollback` |
| 📜 **history** | `sudo nixos-rebuild list-generations` |
| 🧹 **cleanup** | `cleanup` (fish) — old generations + old tags, counter keeps going |

## 🎨 Where to change what

| I want to... | Go to |
| --- | --- |
| add / remove an app | `home.packages` in `home/kaan/caelestia.nix` |
| change keybinds, apps on keys, gaps, blur | `hypr-vars.lua` in `home/kaan/caelestia.nix` |
| add window rules | `hypr-user.lua` in `home/kaan/caelestia.nix` |
| fix something in the upstream dots | add a patch in `patches/` |
| shell look & behaviour | the Caelestia settings app (writes `shell.json`) |

## 🌱 Housekeeping

- **Versioning** lives in `.version` (source of truth) and every successful
  `rebuild` bumps it by one, tagging `nixos-<n>` and pushing it. The number
  is independent of Nix generations, so it always counts up and cleanup can
  never reset it.
- `cleanup` deletes all old Nix generations and all old `nixos-*` tags but
  keeps the current generation, the current tag and the `.version` counter —
  the next rebuild just continues from where you left off.
- Every `switch` creates a **generation** — a bootable snapshot. Keep a few
  for safety, clean the rest with `cleanup`.

## 🤍 Built with love, Nix, and way too much caffeine
