# Nintendo Switch

This is the small, useful part of my CFW SD card.

It keeps boot entries, Atmosphere settings and hosts, enabled sysmodule flags,
homebrew preferences, emuMMC location data, and the Hekate menu icons referenced
by `hekate_ipl.ini`.

It intentionally does not include games, firmware, NAND or PRODINFO backups,
console keys, certificates, tokens, saves, screenshots, cheats, logs, caches,
homebrew binaries, payloads, installed themes, or emulator data.

Refresh the snapshot while the SD card is mounted:

```sh
scripts/sync-switch-cfw.sh
```

`sd/emuMMC/emummc.ini` describes the current SD partition layout. Do not copy it
to a different card without checking the sector and paths first.

## macOS cleanup

`scripts/switch-sd-clean.sh` removes AppleDouble files, `.DS_Store`, accessible
macOS volume metadata, and Windows volume metadata. Pass `--deep` to also clear
known CFW and homebrew logs, crash reports, temporary folders, and caches.

The macOS LaunchAgent runs the metadata-only cleanup every ten minutes while the
card is mounted. Command-line copies should still use `cp -X` or `ditto --norsrc`
so extended attributes never reach FAT32 in the first place.

macOS can protect `.Spotlight-V100` and `.Trashes` from normal user processes.
The cleaner skips them when the OS denies deletion. Spotlight indexing and
`.DS_Store` writing are disabled separately on the Mac.
