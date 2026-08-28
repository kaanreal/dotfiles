#!/usr/bin/env bash
# Install the small set of root-owned files used by the Arch side.

set -euo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"

required_uuids=(
  D147-B3BE
  f98d008c-c950-4b12-b851-c93d46992162
  ddedd945-3579-4958-8a4e-f47619d88f6a
  5c55d484-275c-4895-9fde-da7ffe0d1398
)

for uuid in "${required_uuids[@]}"; do
  if [[ ! -e "/dev/disk/by-uuid/$uuid" ]]; then
    echo "refusing to install host config: missing filesystem $uuid" >&2
    exit 1
  fi
done

sudo install -Dm755 \
  "$repo/scripts/sync-arch-kernels.sh" \
  /usr/local/sbin/sync-arch-kernels
sudo install -Dm755 \
  "$repo/scripts/update-live-limine-arch.sh" \
  /usr/local/sbin/update-live-limine-arch
sudo install -Dm644 \
  "$repo/devices/arch/etc/pacman.d/hooks/zz-sync-arch-kernels.hook" \
  /etc/pacman.d/hooks/zz-sync-arch-kernels.hook
sudo install -Dm644 \
  "$repo/devices/arch/etc/systemd/system/nvidia-clocks.service" \
  /etc/systemd/system/nvidia-clocks.service
sudo install -Dm644 \
  "$repo/devices/arch/etc/mkinitcpio.conf" \
  /etc/mkinitcpio.conf
sudo install -Dm644 \
  "$repo/devices/arch/etc/fstab" \
  /etc/fstab

sudo rm -f /etc/mkinitcpio.conf.d/10-resume.conf
sudo systemctl daemon-reload
sudo systemctl enable nvidia-clocks.service
sudo systemctl restart nvidia-clocks.service
sudo swapon -a
sudo mkinitcpio -P
sudo /usr/local/sbin/sync-arch-kernels
sudo /usr/local/sbin/update-live-limine-arch
