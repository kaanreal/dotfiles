#!/usr/bin/env bash

set -euo pipefail

sd="${1:-/Volumes/SWITCH SD}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="$repo_root/devices/switch/sd"

if [[ ! -d "$sd/atmosphere" || ! -d "$sd/bootloader" ]]; then
  printf 'not a Switch CFW SD: %s\n' "$sd" >&2
  exit 1
fi

files=(
  HATS_VERSION.txt
  boot.ini
  exosphere.ini
  SaltySD/exceptions.txt
  atmosphere/config/system_settings.ini
  atmosphere/hosts/default.txt
  atmosphere/hosts/emummc.txt
  atmosphere/hosts/sysmmc.txt
  bootloader/hekate_ipl.ini
  bootloader/nyx.ini
  bootloader/res/emummc.bmp
  bootloader/res/ofw.bmp
  bootloader/res/stock.bmp
  bootloader/res/sysnand.bmp
  config/Fizeau/config.ini
  config/JKSV/JKSV.json
  config/SimpleModManager/parameters.ini
  config/hats-tools/config.ini
  config/nx-hbmenu/settings.cfg
  config/quickntp.ini
  config/sphaira/appstoreAPI.ini
  config/sphaira/config.ini
  config/sys-patch/config.ini
  config/tesla/config.ini
  config/ultrahand/config.ini
  config/ultrahand/overlays.ini
  config/ultrahand/packages.ini
  config/ultrahand/theme.ini
  config/ultrahand/themes/classic.ini
  config/ultrahand/themes/ultra-blue.ini
  config/ultrahand/themes/ultra.ini
  emuMMC/emummc.ini
  emuiibo/overlay/favorites.txt
)

/bin/rm -rf "$target"
/bin/mkdir -p "$target"

copy_one() {
  local relative="$1"
  local source="$sd/$relative"
  local destination="$target/$relative"

  [[ -f "$source" ]] || return 0
  /bin/mkdir -p "$(dirname "$destination")"
  /bin/cp -X "$source" "$destination"
  /bin/chmod 644 "$destination"
}

for relative in "${files[@]}"; do
  copy_one "$relative"
done

while IFS= read -r -d '' source; do
  copy_one "${source#"$sd/"}"
done < <(
  /usr/bin/find "$sd/atmosphere/contents" -type f \
    \( -name 'toolbox.json' -o -path '*/flags/*.flag' -o -name 'mitm.lst' -o -name 'fsmitm.flag' -o -name 'ver.txt' \) \
    -print0
)

/usr/bin/find "$target" -type f \
  \( -name '*.ini' -o -name '*.cfg' -o -name '*.json' -o -name '*.txt' -o -name '*.flag' -o -name '*.lst' \) \
  -exec /usr/bin/env LC_ALL=C LANG=C /usr/bin/perl -0777 -pi -e 's/\r\n/\n/g; s/[ \t]+$//mg; s/\n+\z/\n/' {} +

if /usr/bin/find "$target" -type f \
  \( -iname '*key*' -o -iname '*prodinfo*' -o -iname '*bis*' -o -iname '*cert*' -o -iname '*token*' -o -iname '*password*' -o -iname '*secret*' \) \
  -print -quit | /usr/bin/grep -q .; then
  printf 'refusing snapshot: a sensitive filename passed the allowlist\n' >&2
  exit 1
fi

if /usr/bin/grep -RIEq 'BEGIN [A-Z ]*PRIVATE KEY|api_key[[:space:]]*=[[:space:]]*[^[:space:]]+|pass(word)?[[:space:]]*=[[:space:]]*[^[:space:]]+' "$target"; then
  printf 'refusing snapshot: possible credential found\n' >&2
  exit 1
fi

printf 'updated %s\n' "$target"
