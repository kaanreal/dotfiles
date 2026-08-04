# arch-desktop

The Arch machine has **no host-level flake config yet** — it's a plain Arch
install that reuses this repo's shared dots and the Arch-specific setup under
`devices/linux/`.

Fresh install: `scripts/install-arch.sh` (from the live ISO).
Standalone setup: `devices/linux/setup.sh`.

When this machine gets a NixOS-style declarative config, it lands in this
directory (hosts/arch-desktop/default.nix) and gets wired into `flake.nix`.
