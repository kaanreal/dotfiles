# macOS (planned — not yet set up)

The third machine in this multi-OS home. Nothing has run here yet; this
directory is the bootstrap for the day a Mac joins.

## Layout

- `scripts/install-macos.sh` — one-shot: Homebrew + repo clone + shared links.
- `devices/macos/setup.sh` — macOS specifics (fish, starship, Dock/defaults).
- `devices/macos/setup/fish/` — macOS fish config (adapted, no pacman aliases).
- `devices/macos/setup/starship.toml` — same prompt as everywhere else.

Shared configs (kitty, fastfetch, starship, btop, micro) live in `dots/`
inside the same repo and are reused unchanged, so they stay in sync across
all three OSes.

## When the Mac arrives

```sh
xcode-select --install
curl -LO https://raw.githubusercontent.com/kaanreal/cozy-home/main/scripts/install-macos.sh
chmod +x install-macos.sh && ./install-macos.sh
# then set fish as the login shell and:
~/cozy-home/devices/macos/setup.sh --defaults
```
