#!/usr/bin/env bash
# Link the shared Linux configs into this user's home.
# Existing files are moved to one dated backup before anything is replaced.

set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DOTS="$REPO/dots"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_ROOT="$HOME/.local/state/dotfiles-backups/$STAMP"
BACKED_UP=0

directory_links=(
  "hypr:hypr"
  "caelestia:caelestia"
  "fish:fish"
  "foot:foot"
  "kitty:kitty"
  "fastfetch:fastfetch"
  "btop:btop"
  "micro:micro"
  "thunar:Thunar"
  "nvim:nvim"
  "uwsm:uwsm"
)

mkdir -p "$CONFIG_HOME"

link_one() {
  local source_name="$1"
  local target_name="$2"
  local source_path="$DOTS/$source_name"
  local target_path="$CONFIG_HOME/$target_name"

  if [[ ! -e "$source_path" ]]; then
    echo "missing repo config: $source_path" >&2
    exit 1
  fi

  if [[ -L "$target_path" && "$(readlink -f "$target_path")" == "$(readlink -f "$source_path")" ]]; then
    echo "ok      $target_path"
    return
  fi

  if [[ -e "$target_path" || -L "$target_path" ]]; then
    mkdir -p "$BACKUP_ROOT/$(dirname "$target_name")"
    mv "$target_path" "$BACKUP_ROOT/$target_name"
    BACKED_UP=1
    echo "backup  $target_path"
  fi

  mkdir -p "$(dirname "$target_path")"
  ln -s "$source_path" "$target_path"
  echo "link    $target_path -> $source_path"
}

for entry in "${directory_links[@]}"; do
  source_name="${entry%%:*}"
  target_name="${entry#*:}"
  link_one "$source_name" "$target_name"
done

file_links=(
  "starship.toml:starship.toml"
  "vscode/settings.json:Code/User/settings.json"
  "vscode/keybindings.json:Code/User/keybindings.json"
  "vscode/flags.conf:code-flags.conf"
  "zed/settings.json:zed/settings.json"
  "zed/keymap.json:zed/keymap.json"
  "opencode/opencode.jsonc:opencode/opencode.jsonc"
  "spicetify/Themes/caelestia/user.css:spicetify/Themes/caelestia/user.css"
)

for entry in "${file_links[@]}"; do
  source_name="${entry%%:*}"
  target_name="${entry#*:}"
  link_one "$source_name" "$target_name"
done

# Arch's caelestia-shell package exposes its Quickshell config through
# /etc/xdg. A checkout in ~/.config shadows that package and never updates.
shell_override="$CONFIG_HOME/quickshell/caelestia"
if [[ -f /etc/xdg/quickshell/caelestia/shell.qml && ( -e "$shell_override" || -L "$shell_override" ) ]]; then
  mkdir -p "$BACKUP_ROOT/quickshell"
  mv "$shell_override" "$BACKUP_ROOT/quickshell/caelestia"
  BACKED_UP=1
  echo "backup  $shell_override (using packaged shell)"
fi

if (( BACKED_UP )); then
  echo "old configs: $BACKUP_ROOT"
fi
