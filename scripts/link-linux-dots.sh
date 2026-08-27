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

links=(
  "hypr:hypr"
  "caelestia:caelestia"
  "fish:fish"
  "foot:foot"
  "kitty:kitty"
  "fastfetch:fastfetch"
  "btop:btop"
  "micro:micro"
  "thunar:Thunar"
  "starship.toml:starship.toml"
)

mkdir -p "$CONFIG_HOME"

for entry in "${links[@]}"; do
  source_name="${entry%%:*}"
  target_name="${entry#*:}"
  source_path="$DOTS/$source_name"
  target_path="$CONFIG_HOME/$target_name"

  if [[ ! -e "$source_path" ]]; then
    echo "missing repo config: $source_path" >&2
    exit 1
  fi

  if [[ -L "$target_path" && "$(readlink -f "$target_path")" == "$(readlink -f "$source_path")" ]]; then
    echo "ok      $target_path"
    continue
  fi

  if [[ -e "$target_path" || -L "$target_path" ]]; then
    mkdir -p "$BACKUP_ROOT"
    mv "$target_path" "$BACKUP_ROOT/$target_name"
    BACKED_UP=1
    echo "backup  $target_path"
  fi

  ln -s "$source_path" "$target_path"
  echo "link    $target_path -> $source_path"
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
