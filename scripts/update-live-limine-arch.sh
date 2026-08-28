#!/usr/bin/env bash
# Replace only the Arch tail of NixOS' generated Limine configuration.

set -euo pipefail

if (( EUID != 0 )); then
  echo "run as root" >&2
  exit 1
fi

config=/efi/limine/limine.conf
marker='# NixOS boot entries end here'

if [[ ! -f "$config" ]] || ! grep -qxF "$marker" "$config"; then
  echo "missing expected NixOS marker in $config" >&2
  exit 1
fi

temporary="$(mktemp /efi/limine/.limine.conf.XXXXXX)"
cleanup() {
  rm -f "$temporary"
}
trap cleanup EXIT

sed -n "1,/$marker/p" "$config" >"$temporary"
printf '%s\n' \
  '' \
  '/Arch' \
  '    protocol: linux' \
  '    path: boot():/arch/vmlinuz-linux-cachyos' \
  '    module_path: boot():/arch/initramfs-linux-cachyos.img' \
  '    cmdline: root=UUID=ddedd945-3579-4958-8a4e-f47619d88f6a resume=UUID=5c55d484-275c-4895-9fde-da7ffe0d1398 rw quiet splash loglevel=3 nvidia-drm.modeset=1 nvidia-drm.fbdev=1' \
  '' \
  '/Arch (stock)' \
  '    protocol: linux' \
  '    path: boot():/arch/vmlinuz-linux' \
  '    module_path: boot():/arch/initramfs-linux.img' \
  '    cmdline: root=UUID=ddedd945-3579-4958-8a4e-f47619d88f6a resume=UUID=5c55d484-275c-4895-9fde-da7ffe0d1398 rw quiet splash loglevel=3 nvidia-drm.modeset=1 nvidia-drm.fbdev=1' \
  >>"$temporary"

chmod 600 "$temporary"
mv -f "$temporary" "$config"
sync -f "$(dirname "$config")"

echo "updated Arch entries in $config"
