#!/usr/bin/env bash
#
# kaan's Arch dotfiles setup.
#
# Links the shared dotfiles (kitty, fastfetch) from ~/dotfiles and installs
# the Arch-side configs (fish, starship, hyprland) into the user's home.
# Runs from the chroot during install.sh, or standalone on a running Arch
# box:  ./arch/setup.sh
#
# Optional flag:  --with-desktop   installs a minimal Hyprland desktop.
#
# ~/dotfiles is the caelestia-dots/caelestia fork (git), so it stays in
# sync with NixOS and upstream. Set DOTFILES_DIR to override its location.

set -euo pipefail

REPO="${REPO_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
USERNAME="${USERNAME:-${SUDO_USER:-$USER}}"
HOME_DIR="$(eval echo "~${USERNAME}")"
DOTFILES="${DOTFILES_DIR:-${HOME_DIR}/dotfiles}"

WITH_DESKTOP=0
[[ "${1:-}" == "--with-desktop" ]] && WITH_DESKTOP=1

need_root() {
  if [[ $EUID -eq 0 ]]; then
    echo "==> This step must run as the user (${USERNAME}), not root. Run:"
    echo "    su - ${USERNAME} -c '$REPO/arch/setup.sh ${1:-}'"
    exit 1
  fi
}

# --- shared dotfiles ---------------------------------------------------------
if [[ ! -d "${DOTFILES}/kitty" ]]; then
  echo "==> dotfiles repo not found at ${DOTFILES} — cloning"
  git clone https://github.com/kaanreal/dotfiles.git "${DOTFILES}"
fi
echo "==> Linking shared dotfiles"
mkdir -p "${HOME_DIR}/.config"
ln -sfn "${DOTFILES}/kitty"    "${HOME_DIR}/.config/kitty"
ln -sfn "${DOTFILES}/fastfetch" "${HOME_DIR}/.config/fastfetch"

# --- Arch-specific dotfiles ---------------------------------------------------
echo "==> Installing Arch dotfiles (fish, starship)"
mkdir -p "${HOME_DIR}/.config"
cp -rn "${REPO}/arch/setup/fish"        "${HOME_DIR}/.config/"
ln -sfn "${REPO}/arch/setup/starship.toml" "${HOME_DIR}/.config/starship.toml"

# --- optional desktop ---------------------------------------------------------
if [[ "${WITH_DESKTOP}" == "1" ]]; then
  need_root --with-desktop
  echo "==> Installing Hyprland desktop packages"
  sudo pacman -S --needed --noconfirm \
    hyprland waybar foot wofi mako swww swaylock swayidle \
    xdg-desktop-portal-hyprland polkit-kde-agent \
    wl-clipboard grim slurp brightnessctl pamixer pavucontrol \
    ttf-jetbrains-mono-nerd noto-fonts ttf-dejavu \
    wireplumber pipewire-pulse

  echo "==> Installing Hyprland config"
  mkdir -p "${HOME_DIR}/.config"
  cp -rn "${REPO}/arch/setup/hypr"   "${HOME_DIR}/.config/"
  cp -rn "${REPO}/arch/setup/waybar" "${HOME_DIR}/.config/"

  echo "==> Enabling greetd (login manager, autostarts Hyprland)"
  sudo pacman -S --needed --noconfirm greetd
  sudo mkdir -p /etc/greetd
  sudo tee /etc/greetd/config.toml > /dev/null <<'EOF'
[terminal]
vt = 1

[default_session]
user = "auto"
command = "Hyprland"
EOF
  sudo systemctl enable greetd

  echo "==> Desktop ready. Next boot it starts with 'Hyprland'."
  echo "    First autostart runs 'swww init' with arch/setup/wallpaper."
fi

echo
echo "=== Dotfiles setup complete ==="
echo "kitty / fastfetch: shared via ~/dotfiles (git fork of caelestia-dots)"
echo "fish / starship:   Arch-specific in arch/setup/"
echo
if [[ "${WITH_DESKTOP}" != "1" ]]; then
  echo "Want a desktop too? Run: $REPO/arch/setup.sh --with-desktop"
fi
