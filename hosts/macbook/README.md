# macbook

The Mac has **no host-level config yet** — it reuses the shared dots and the
macOS-specific setup under `devices/macos/`.

Fresh setup: `scripts/install-macos.sh`, then `devices/macos/setup.sh --defaults`.

When this machine gets a declarative config (nix-darwin or similar), it lands
in this directory (hosts/macbook/default.nix) and gets wired into `flake.nix`.
