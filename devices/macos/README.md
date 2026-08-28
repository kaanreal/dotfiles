# macOS

Run `scripts/link-macos-dots.sh` after cloning the repository to
`~/dotfiles`. It links the portable shell configs, the macOS Fastfetch and Git
files, and the Switch SD cleanup LaunchAgent. Existing files are moved under
`~/.local/state/dotfiles-backups/` first.

The script expects Homebrew Fish, Starship, btop, Micro, Fastfetch, and Git LFS
to be installed separately.
