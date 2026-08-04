#!/usr/bin/env bash
#
# kaan's Arch Linux setup.
#
# Links the shared dotfiles (kitty, fastfetch, starship, btop, micro) from
# this repo's dots/ (the vendored caelestia fork) and installs the Arch-side
# configs (fish, hyprland, waybar) into the user's home.
# Runs from the chroot during scripts/install-arch.sh, or standalone on a
# running Arch box:  ./devices/linux/setup.sh
#
# Optional flag:  --with-desktop   installs a minimal Hyprland desktop.

set -euo pipefail

REPO="${REPO_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
USERNAME="${USERNAME:-${SUDO_USER:-$USER}}"
HOME_DIR="$(eval echo "~${USERNAME}")"
DOTS="${DOTS_DIR:-${REPO}/dots}"

WITH_DESKTOP=0
[[ "${1:-}" == "--with-desktop" ]] && WITH_DESKTOP=1

need_root() {
  if [[ $EUID -eq 0 ]]; then
    echo "==> This step must run as the user (${USERNAME}), not root. Run:"
    echo "    su - ${USERNAME} -c '$REPO/devices/linux/setup.sh ${1:-}'"
    exit 1
  fi
}

# --- shared dotfiles ---------------------------------------------------------
if [[ ! -d "${REPO}/.git" ]]; then
  echo "==> cozy-home repo not found at ${REPO} — cloning"
  git clone https://github.com/kaanreal/cozy-home.git "${REPO}"
fi
echo "==> Linking shared dotfiles from dots/"
mkdir -p "${HOME_DIR}/.config"
ln -sfn "${DOTS}/kitty"      "${HOME_DIR}/.config/kitty"
ln -sfn "${DOTS}/fastfetch"  "${HOME_DIR}/.config/fastfetch"
ln -sfn "${DOTS}/starship.toml" "${HOME_DIR}/.config/starship.toml"
ln -sfn "${DOTS}/btop"       "${HOME_DIR}/.config/btop"
ln -sfn "${DOTS}/micro"      "${HOME_DIR}/.config/micro"

# --- Arch-specific dotfiles ---------------------------------------------------
echo "==> Installing Arch dotfiles (fish, starship)"
mkdir -p "${HOME_DIR}/.config"
cp -rn "${REPO}/devices/linux/setup/fish"        "${HOME_DIR}/.config/"
ln -sfn "${REPO}/devices/linux/setup/starship.toml" "${HOME_DIR}/.config/starship.toml"

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
  cp -rn "${REPO}/devices/linux/setup/hypr"   "${HOME_DIR}/.config/"
  cp -rn "${REPO}/devices/linux/setup/waybar" "${HOME_DIR}/.config/"

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
  echo "    First autostart runs 'swww init' with devices/linux/setup/wallpaper."
fi

echo
echo "=== Setup complete ==="
echo "kitty / fastfetch / starship / btop / micro: shared via dots/ (vendored caelestia)"
echo "fish / waybar / hyprland:                 Arch-specific in devices/linux/setup/"
echo
if [[ "${WITH_DESKTOP}" != "1" ]]; then
  echo "Want a desktop too? Run: $REPO/devices/linux/setup.sh --with-desktop"
fi
