# Arch

Run both installers after cloning:

```sh
scripts/link-linux-dots.sh
scripts/install-arch-system-files.sh
```

The second script installs the pacman hook that copies regenerated stock and
CachyOS kernels from `/boot` to `/efi/arch`. Limine reads those copies from the
shared ESP. The hook runs after mkinitcpio and NVIDIA package hooks.

The installer also enables `nvidia-clocks.service`. It creates the NVIDIA
device nodes after boot, enables persistence mode, and locks the RTX 3050 to
1552 MHz graphics and 7001 MHz memory clocks.
