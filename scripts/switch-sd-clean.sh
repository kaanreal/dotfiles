#!/usr/bin/env bash

set -euo pipefail

volume="${SWITCH_SD_VOLUME:-/Volumes/SWITCH SD}"
deep_clean=false

if [[ "${1:-}" == "--deep" ]]; then
  deep_clean=true
elif [[ -n "${1:-}" ]]; then
  volume="$1"
fi

if [[ ! -d "$volume/atmosphere" || ! -d "$volume/bootloader" ]]; then
  exit 0
fi

if ! /sbin/mount | /usr/bin/grep -F " on $volume (" >/dev/null; then
  printf 'not a mounted Switch SD: %s\n' "$volume" >&2
  exit 1
fi

metadata_dirs=(
  "$volume/.Spotlight-V100"
  "$volume/.Trashes"
  "$volume/.fseventsd"
  "$volume/.TemporaryItems"
  "$volume/.DocumentRevisions-V100"
  "$volume/.AppleDB"
  "$volume/.AppleDesktop"
  "$volume/Network Trash Folder"
  "$volume/Temporary Items"
  "$volume/System Volume Information"
)

for path in "${metadata_dirs[@]}"; do
  if [[ -e "$path" ]] && ! /bin/rm -rf "$path" 2>/dev/null; then
    [[ -t 2 ]] && printf 'could not remove protected metadata: %s\n' "$path" >&2
  fi
done

/usr/bin/find "$volume" -xdev -type f \
  \( -name '._*' -o -name '.DS_Store' -o -name 'Thumbs.db' -o -name 'desktop.ini' \) \
  -delete 2>/dev/null || true

if "$deep_clean"; then
  generated_dirs=(
    "$volume/.mesa"
    "$volume/dumps"
    "$volume/atmosphere/crash_reports"
    "$volume/atmosphere/fatal_errors"
    "$volume/atmosphere/fatal_reports"
    "$volume/atmosphere/logs"
    "$volume/retroarch/logs"
    "$volume/switch/Goldleaf/export/temp"
    "$volume/switch/DBI/logs"
    "$volume/switch/appstore/.get/tmp"
    "$volume/switch/Cemu/cache"
    "$volume/switch/hats-tools/cache"
    "$volume/switch/lbbg_nx/cache"
    "$volume/switch/sphaira/cache"
    "$volume/switch/tinfoil/cache"
    "$volume/tico/config/cache"
    "$volume/tico/data/cache"
    "$volume/tico/system/gc/User/Wii/tmp"
  )

  generated_files=(
    "$volume/prelude_exit.log"
    "$volume/prelude_trace.txt"
    "$volume/SaltySD/saltysd.log"
    "$volume/SaltySD/saltysd_core.log"
    "$volume/avatars/nso-icon-tool/log.log"
    "$volume/config/sys-patch/log.ini"
    "$volume/switch/Goldleaf/goldleaf.log"
    "$volume/switch/nxdt_rw_poc/nxdt_rw_poc.log"
  )

  for path in "${generated_dirs[@]}" "${generated_files[@]}"; do
    [[ -e "$path" ]] && /bin/rm -rf "$path"
  done
fi

printf 'cleaned %s\n' "$volume"
