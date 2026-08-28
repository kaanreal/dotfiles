#!/usr/bin/env bash
# Link the portable and macOS-specific configs into the current Mac account.

set -euo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
stamp="$(date +%Y%m%d-%H%M%S)"
backup_root="$HOME/.local/state/dotfiles-backups/$stamp-macos"
backed_up=0

link_one() {
  local source_path="$1"
  local target_path="$2"
  local relative="${target_path#"$HOME"/}"

  if [[ ! -e "$source_path" ]]; then
    echo "missing repo config: $source_path" >&2
    exit 1
  fi

  if [[ -L "$target_path" && "$(readlink "$target_path")" == "$source_path" ]]; then
    echo "ok      $target_path"
    return
  fi

  if [[ -e "$target_path" || -L "$target_path" ]]; then
    mkdir -p "$backup_root/$(dirname "$relative")"
    mv "$target_path" "$backup_root/$relative"
    backed_up=1
    echo "backup  $target_path"
  fi

  mkdir -p "$(dirname "$target_path")"
  ln -s "$source_path" "$target_path"
  echo "link    $target_path -> $source_path"
}

link_one "$repo/dots/fish" "$config_home/fish"
link_one "$repo/dots/btop" "$config_home/btop"
link_one "$repo/dots/micro" "$config_home/micro"
link_one "$repo/dots/starship.toml" "$config_home/starship.toml"
link_one "$repo/devices/macos/dots/fastfetch" "$config_home/fastfetch"
link_one "$repo/devices/macos/dots/git/gitconfig" "$HOME/.gitconfig"
link_one "$repo/devices/macos/dots/git/gitignore_global" "$HOME/.gitignore_global"
link_one "$repo/scripts/switch-sd-clean.sh" "$HOME/.local/bin/switch-sd-clean"
link_one "$repo/devices/macos/launchagents/com.kaanreal.switch-sd-cleaner.plist" \
  "$HOME/Library/LaunchAgents/com.kaanreal.switch-sd-cleaner.plist"

launchctl bootout "gui/$UID/com.kaanreal.switch-sd-cleaner" >/dev/null 2>&1 || true
launchctl bootstrap "gui/$UID" "$HOME/Library/LaunchAgents/com.kaanreal.switch-sd-cleaner.plist"

if (( backed_up )); then
  echo "old configs: $backup_root"
fi
