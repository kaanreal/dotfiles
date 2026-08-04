# macOS (planned — not yet set up)

The third machine in this multi-OS home. Nothing has run here yet; this
directory is the bootstrap for the day a Mac joins.

## Layout

- `bootstrap.sh` — one-shot: Homebrew + dotfiles clone + shared links.
- `setup.sh` — macOS specifics (fish, starship, Dock/defaults).
- `setup/fish/` — macOS fish config (adapted, no pacman aliases).
- `setup/starship.toml` — same prompt as everywhere else.

Shared configs (kitty, fastfetch) live in `dotfiles/` and are reused
unchanged, so they stay in sync across all three OSes.

## When the Mac arrives

```sh
xcode-select --install
curl -LO https://raw.githubusercontent.com/kaanreal/nix/main/mac/bootstrap.sh
chmod +x bootstrap.sh && ./bootstrap.sh
# then set fish as the login shell and:
~/.dotfiles/mac/setup.sh --defaults
```
