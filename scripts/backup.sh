#!/usr/bin/env bash
#
# Snapshot the whole dotfiles repo (git history included) into ~/.backups/.
# Keeps the last 5 tarballs.
#
# run:  ./scripts/backup.sh

set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${BACKUP_DIR:-$HOME/.backups}"
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT="$DEST/dotfiles-$STAMP.tar.gz"

mkdir -p "$DEST"
tar czf "$OUT" -C "$(dirname "$REPO")" "$(basename "$REPO")"

# Bash globbing works on both GNU/Linux and macOS. The timestamped names sort
# oldest first, so prune from the front until five snapshots remain.
shopt -s nullglob
backups=("$DEST"/dotfiles-*.tar.gz)
while (( ${#backups[@]} > 5 )); do
  rm -f -- "${backups[0]}"
  backups=("${backups[@]:1}")
done

echo "backed up to $OUT"
printf '%s\n' "${backups[@]}"
