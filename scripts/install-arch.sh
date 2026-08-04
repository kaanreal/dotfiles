#!/usr/bin/env bash
#
# Arch Linux installer for kaan's multi-OS home.
#
# Run this from the Arch live ISO. It performs the DISK SURGERY that
# cannot be done from the running NixOS: it shrinks the mounted-less
# NixOS root partition on the Crucial SSD, creates one Arch partition,
# and installs a base Arch system whose boot entries are served by the
# Limine bootloader that NixOS manages (no bootloader is installed on
# the Arch side).
#
# Layout after this script (Crucial SSD, /dev/nvme0n1):
#   p1  1G     vfat  /boot          ESP  -> Limine (managed by NixOS)
#   p2  ~400G  ext4  /              NixOS root (shrunk from 913.8G)
#   p4  ~500G  ext4  (label archroot)   Arch root
#   p3  16.8G  swap                 NixOS swap (untouched)
#
# Arch uses a swapfile inside archroot — no extra partition needed.
# Limine boots Arch via `fslabel(archroot)`, so Arch never writes to the
# shared ESP and never installs a bootloader.
#
# DANGER: repartitions the disk and resizes the NixOS root filesystem.
# It only touches the partitions listed below; Windows (nvme1n1) is
# never modified. Read the whole script before running it.

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration — adjust sizes here if you want a different split.
# ---------------------------------------------------------------------------
DISK=/dev/nvme0n1
ESP_PART=1                       # shared ESP (Limine lives here)
NIXOS_ROOT_PART=2                # NixOS root ext4, will be shrunk
NIXOS_SWAP_PART=3                # NixOS swap, untouched
NIXOS_ROOT_NEW_SIZE=400G         # NixOS root after shrinking
ARCH_ROOT_SIZE=500G              # size of the new Arch partition
ARCH_LABEL=archroot              # must match boot.loader.limine.extraEntries
ARCH_SWAP_SIZE=8G                # swapfile inside archroot
ARCH_SWAPFILE=/swapfile

HOSTNAME=arch
USERNAME=kaan
TIMEZONE=Europe/Berlin
LOCALE=en_US.UTF-8
KEYMAP=de

REPO_URL=https://github.com/kaanreal/cozy-home.git
REPO_DIR=/home/kaan/cozy-home

# The dotfiles live inside the same repo at dots/. The setup script
# (devices/linux/setup.sh) links them from there.

# ---------------------------------------------------------------------------
# Safety checks — never run this against the wrong disk.
# ---------------------------------------------------------------------------
die() { echo "ERROR: $*" >&2; exit 1; }
confirm() {
  echo "You are about to:"
  echo "  1. Shrink ${DISK}${NIXOS_ROOT_PART} (NixOS root) to ${NIXOS_ROOT_NEW_SIZE}"
  echo "  2. Create a ${ARCH_ROOT_SIZE} Arch root partition labeled '${ARCH_LABEL}'"
  echo "     with a ${ARCH_SWAP_SIZE} swapfile"
  echo "  3. Install a base Arch system (hostname ${HOSTNAME}, user ${USERNAME})"
  echo "  4. Pull dotfiles from ${REPO_URL}"
  echo "Windows on nvme1n1 is NOT touched."
  read -r -p "Type 'yes' to continue: " answer
  [[ "$answer" == "yes" ]] || die "aborted"
}

[ -e "${DISK}${NIXOS_ROOT_PART}" ] || die "${DISK}${NIXOS_ROOT_PART} not found"
[ -e /sys/firmware/efi ] || die "this machine is not booted in UEFI mode"
mount | grep -q " on /mnt " && die "/mnt already in use — unmount it first"
[ "$(whoami)" == "root" ] || die "run this as root from the live ISO"

confirm

# ---------------------------------------------------------------------------
# 1. Shrink the NixOS root filesystem + partition.
#    ext4 is shrunk offline (filesystem first, then the partition).
# ---------------------------------------------------------------------------
echo "==> Shrinking ${DISK}${NIXOS_ROOT_PART} to ${NIXOS_ROOT_NEW_SIZE}"
e2fsck -f "${DISK}${NIXOS_ROOT_PART}"
resize2fs "${DISK}${NIXOS_ROOT_PART}" "${NIXOS_ROOT_NEW_SIZE}"

echo "==> Resizing partition ${NIXOS_ROOT_PART} to match"
parted --align optimal "${DISK}" resizepart "${NIXOS_ROOT_PART}" "${NIXOS_ROOT_NEW_SIZE}"
partprobe "${DISK}"
sleep 2

# ---------------------------------------------------------------------------
# 2. Create the Arch root partition in the freed space (between the
#    shrunken NixOS root and the NixOS swap at the end of the disk).
# ---------------------------------------------------------------------------
echo "==> Creating Arch root partition (${ARCH_ROOT_SIZE}, label ${ARCH_LABEL})"
parted --align optimal "${DISK}" mkpart primary ext4 start "${ARCH_ROOT_SIZE}" end -"1G"
partprobe "${DISK}"
sleep 2

ARCH_PART="$(lsblk -lno NAME,LABEL "${DISK}" | awk -v l="$ARCH_LABEL" '$2==l {print "/dev/"$1}')"
# The partition was just created and is not labeled yet; fall back to the
# last partition number (the one we just added).
if [ -z "${ARCH_PART}" ]; then
  ARCH_PART="${DISK}$(lsblk -npo NAME "${DISK}" | wc -l)"
fi
echo "==> Formatting ${ARCH_PART} as ext4 (label ${ARCH_LABEL})"
mkfs.ext4 -L "${ARCH_LABEL}" "${ARCH_PART}"

# ---------------------------------------------------------------------------
# 3. Install the base system.
# ---------------------------------------------------------------------------
echo "==> Mounting and pacstrap"
mount "${ARCH_PART}" /mnt
mkdir -p /mnt/boot
# The shared ESP is mounted at /efi (not /boot) so Arch's kernel stays in
# archroot:/boot — that is exactly the path the Limine entry references.
mount "${DISK}${ESP_PART}" /mnt/efi

PACKAGES=(
  base base-devel linux linux-firmware linux-headers
  networkmanager sudo reflector
  git fish starship kitty fastfetch btop eza ripgrep bat zoxide fzf
  neovim vim tmux htop pacman-contrib openssh
)
pacstrap -K /mnt "${PACKAGES[@]}"

echo "==> Generating fstab (by label/UUID)"
genfstab -U /mnt >> /mnt/etc/fstab

# ---------------------------------------------------------------------------
# 4. System configuration inside the chroot.
# ---------------------------------------------------------------------------
echo "==> Configuring the system"

# swapfile (swappiness defaults are fine for a desktop)
truncate -s 0 "/mnt${ARCH_SWAPFILE}"
fallocate -l "${ARCH_SWAP_SIZE}" "/mnt${ARCH_SWAPFILE}"
chmod 600 "/mnt${ARCH_SWAPFILE}"
mkswap "/mnt${ARCH_SWAPFILE}"
echo -e "${ARCH_SWAPFILE}\tnone\tswap\tdefaults\t0 0" >> /mnt/etc/fstab

# time, locale, keymap
arch-chroot /mnt ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
arch-chroot /mnt hwclock --systohc
sed -i "s/^#${LOCALE}/${LOCALE}/" /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
echo "LANG=${LOCALE}" > /mnt/etc/locale.conf
echo "KEYMAP=${KEYMAP}" > /mnt/etc/vconsole.conf

# hostname + hosts
echo "${HOSTNAME}" > /mnt/etc/hostname
cat > /mnt/etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${HOSTNAME}.localdomain ${HOSTNAME}
EOF

# user + sudo (prompts for passwords)
arch-chroot /mnt useradd -m -G wheel -s /bin/bash "${USERNAME}"
echo "==> Set a password for ${USERNAME}:"
arch-chroot /mnt passwd "${USERNAME}"
echo "==> Set the root password:"
arch-chroot /mnt passwd
echo "%wheel ALL=(ALL:ALL) ALL" > /mnt/etc/sudoers.d/wheel
chmod 440 /mnt/etc/sudoers.d/wheel

# initramfs: needs the udev + filesystems hooks (default) so that
# `root=LABEL=archroot` resolves at boot.
arch-chroot /mnt mkinitcpio -P

# NetworkManager on boot
arch-chroot /mnt systemctl enable NetworkManager

# ---------------------------------------------------------------------------
# 5. Dotfiles from the repo.
# ---------------------------------------------------------------------------
echo "==> Cloning cozy-home repo"
arch-chroot /mnt su - "${USERNAME}" -c "git clone ${REPO_URL} '${REPO_DIR}'"
arch-chroot /mnt su - "${USERNAME}" -c "'${REPO_DIR}/devices/linux/setup.sh'"

# ---------------------------------------------------------------------------
# 6. Done.
# ---------------------------------------------------------------------------
echo
echo "=== Installation complete ==="
echo "Arch root:      ${ARCH_PART} (label ${ARCH_LABEL})"
echo "Bootloader:     Limine (shared ESP, managed by NixOS)"
echo
echo "Next steps:"
echo "  1. reboot (or exit the ISO and reboot)"
echo "  2. In the Limine menu pick 'Arch Linux'"
echo "     (the entry already exists in NixOS's limine.conf)"
echo "  3. First boot into Arch: sudo reflector --country Germany --latest 10"
echo "     then 'sudo pacman -Syu'"
echo
echo "NixOS is untouched except for its root partition size."
