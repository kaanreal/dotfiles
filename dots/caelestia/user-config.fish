# Caelestia user fish config — NixOS-specific additions on top of the shared
# fish config in dots/fish. Sourced from ~/.config/caelestia/user-config.fish
# on every new shell.
#
# Shared commands (save, dots-update, fish_greeting, fastfetch) live in
# dots/fish/functions/ and are shared with macOS.

# User-installed scripts (e.g. osu-wine from osu-winello).
set -gx PATH $HOME/.local/bin $PATH

# nh >= 4.4 dropped current-directory flake detection; bare `nh os switch`
# now only falls back to /etc/nixos. Point it at this repo so update/rebuild
# work from any directory.
set -gx NH_OS_FLAKE $HOME/cozy-home

# Apply the system config (system + home) from this repo. Only for Nix
# packages, services, drivers, modules, or system configuration. Dotfile
# edits are already live (out-of-store links into ~/cozy-home/dots).
function rebuild
    set -l repo $HOME/cozy-home
    nh os switch "path:$repo"
end

# Update Nix inputs (nixpkgs, home-manager, caelestia-shell, kernel) and
# rebuild. Does not touch the dots.
function update
    set -l repo $HOME/cozy-home

    nix flake update --flake $repo
    or return 1

    nh os switch "path:$repo"
end

# Free disk space: old generations + garbage (keeps the last week).
function cleanup
    nh clean all
    echo "cleaned up old generations"
end
