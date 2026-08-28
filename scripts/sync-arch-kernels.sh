#!/usr/bin/env bash
# Copy Arch kernels from the separate /boot filesystem to the shared ESP.
# Limine is installed by NixOS and reads these files through boot():/arch.

set -euo pipefail

if (( EUID != 0 )); then
  echo "run as root" >&2
  exit 1
fi

for mountpoint in /boot /efi; do
  if [[ "$(findmnt -rn -o TARGET --target "$mountpoint")" != "$mountpoint" ]]; then
    echo "refusing to copy: $mountpoint is not mounted" >&2
    exit 1
  fi
done

destination=/efi/arch
files=(
  vmlinuz-linux
  initramfs-linux.img
  vmlinuz-linux-cachyos
  initramfs-linux-cachyos.img
)

install -d -m 700 "$destination"

for name in "${files[@]}"; do
  if [[ ! -s "/boot/$name" ]]; then
    echo "missing kernel file: /boot/$name" >&2
    exit 1
  fi
done

# Reclaim space before making temporary copies. The old CachyOS fallback came
# from a disabled preset and was no longer regenerated.
rm -f "$destination/initramfs-linux-cachyos-fallback.img"
for name in "${files[@]}"; do
  rm -f "$destination/.$name.new"
done

for name in "${files[@]}"; do
  source_file="/boot/$name"
  target_file="$destination/$name"
  temporary="$destination/.$name.new"

  install -m 600 "$source_file" "$temporary"
  mv -f "$temporary" "$target_file"
done

sync -f "$destination"

echo "updated Arch kernels in $destination"
