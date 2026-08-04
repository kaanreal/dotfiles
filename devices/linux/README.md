# Arch Linux on the Crucial SSD

Arch shares the machine with NixOS and Windows. It boots from the same
Limine menu that NixOS manages, and its dotfiles are versioned in this
repo alongside everything else.

## Layout

| Partition | Size     | Role                        |
|-----------|----------|-----------------------------|
| nvme0n1p1 | 1G       | ESP, Limine (NixOS-managed) |
| nvme0n1p2 | ~400G    | NixOS root (shrunk)         |
| nvme0n1p4 | ~500G    | Arch root, label `archroot` |
| nvme0n1p3 | 16.8G    | NixOS swap                  |

Arch has no bootloader and no ESP of its own. The Limine entry in
`hosts/nixos-desktop/default.nix` points at the kernel inside the
`archroot` partition:

```
/Arch Linux
    protocol: linux
    path:         fslabel(archroot):/boot/vmlinuz-linux
    module_path:  fslabel(archroot):/boot/initramfs-linux.img
    cmdline:      root=LABEL=archroot rw
```

Because Limine reads ext4 natively, Arch's kernels just stay in
`/boot` on its own root partition — no sync to the ESP is needed, and
kernel updates keep working without touching the bootloader.

## Install (one time)

Boot the **Arch live ISO** and run:

```sh
curl -LO https://raw.githubusercontent.com/kaanreal/cozy-home/main/scripts/install-arch.sh
chmod +x install-arch.sh
./install-arch.sh
```

The script:

1. Shrinks the NixOS root filesystem + partition to 400G (can only be
   done offline, hence the ISO).
2. Creates one ext4 partition labeled `archroot` (500G) + an 8G swapfile.
3. `pacstrap`s a base system and configures it (hostname, locale, user).
4. Clones this repo to `~/cozy-home` and runs `devices/linux/setup.sh`.

Windows is never touched. NixOS keeps its swap, ESP and data.

## What gets installed

- **Base**: `base base-devel linux linux-firmware networkmanager sudo`
- **CLI**: `git fish starship kitty fastfetch btop eza ripgrep bat zoxide
  fzf neovim vim tmux htop openssh pacman-contrib`
- **Desktop** (optional): `hyprland waybar wofi mako swww greetd ...`
  via `devices/linux/setup.sh --with-desktop`

## Dotfiles

- `dots/kitty`, `dots/fastfetch`, `dots/starship.toml`, `dots/btop`,
  `dots/micro` — shared with every OS, symlinked straight from the repo
  (dots/ is a vendored copy of caelestia-dots/caelestia).
- `devices/linux/setup/fish` — Arch fish config (starship, fastfetch greeting,
  `up`/`in`/`se` aliases, `dotpush` backup function).
- `devices/linux/setup/starship.toml` — shared-style starship prompt.
- `devices/linux/setup/hypr`, `devices/linux/setup/waybar` — minimal Hyprland desktop.

`dotpush` backs the whole repo (dots + Arch config included) up to GitHub,
just like `save` does on NixOS.

## Day-to-day

- Update: `up` (= `sudo pacman -Syu`)
- Install/search: `in foo` / `se foo`
- Backup dots: `dotpush`
- Edit dots in `dots/`, then re-run `devices/linux/setup.sh`
