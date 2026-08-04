# Caelestia user fish config
# Editable: sourced from ~/.config/caelestia/user-config.fish on every new shell.

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
    nh os switch $HOME/cozy-home
end

# Update Nix inputs (nixpkgs, home-manager, caelestia-shell, kernel) and
# rebuild. Does not touch the dots.
function update
    set -l repo $HOME/cozy-home

    nix flake update --flake $repo
    or return 1

    nh os switch $repo
end

# Pull upstream Caelestia config changes into dots/ (vendored subtree).
# git fetch + subtree pull; no resets, no discarding conflicts.
function dots-update
    set -l repo $HOME/cozy-home

    if not git -C $repo diff --quiet
        echo "cozy-home has uncommitted changes; commit or stash them first"
        return 1
    end

    if not git -C $repo diff --cached --quiet
        echo "cozy-home has staged changes; commit or stash them first"
        return 1
    end

    git -C $repo fetch caelestia-upstream
    or return 1

    git -C $repo subtree pull --prefix dots caelestia-upstream main
    or begin
        echo "merge needs attention; resolve the conflicts in ~/cozy-home/dots"
        return 1
    end

    echo "Caelestia dots updated. Run hyprctl reload and restart the shell."
end

# Commit + push a snapshot of this repo (no empty commits, no force-push).
function save
    set -l repo $HOME/cozy-home

    if not test -d $repo/.git
        echo "skip: ~/cozy-home is not a git repository"
        return 1
    end

    echo "==> saving ~/cozy-home"

    git -C $repo add -A
    or begin
        echo "failed to stage changes"
        return 1
    end

    if git -C $repo diff --cached --quiet
        echo "    nothing new — skipping commit"
        return 0
    end

    set -l emojis '🌸' '🌷' '🍃' '🧁' '🐰' '🫧' '❄️' '🧸' '🍓' '🐈'
    set -l emoji $emojis[(random 1 (count $emojis))]
    set -l msg "$emoji "(date '+%F %H:%M:%S')
    git -C $repo commit -m "$msg"
    or begin
        echo "commit failed"
        return 1
    end

    if git -C $repo remote get-url origin >/dev/null 2>&1
        git -C $repo push origin
        or echo "    committed, but push failed"
    else
        echo "    no remote — committed locally, skipped push"
    end
end

# Free disk space: old generations + garbage (keeps the last week).
function cleanup
    nh clean all
    echo "cleaned up old generations"
end

# Override the dots' CAELESTIA ASCII banner greeting: fish skips
# autoloading fish_greeting.fish because we define it here first.
function fish_greeting
    command -v fastfetch &> /dev/null && fastfetch
end

# Adaptive fastfetch: shrink the logo so it always fits the window.
# function <name> shadows the real binary, `command fastfetch` bypasses it.
function fastfetch
    set -l cols 80
    if command stty size >/dev/null 2>&1
        set cols (string split ' ' (stty size))[2]
    end
    set -l w 45
    if test $cols -lt 90
        set w 32
    end
    if test $cols -lt 72
        set w 24
    end
    if test $cols -lt 55
        set w 16
    end
    command fastfetch --logo-width $w $argv
end
