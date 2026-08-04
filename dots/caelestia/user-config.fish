# Caelestia user fish config
# Editable: sourced from ~/.config/caelestia/user-config.fish on every new shell.

# User-installed scripts (e.g. osu-wine from osu-winello).
set -gx PATH $HOME/.local/bin $PATH

# Force the container-correct nix-ld env. The login session (started
# before the fix) inherits NIX_LD=/run/current-system/... from an old
# /etc/set-environment; inside the pressure-vessel container that path
# does not exist -> nix-ld ENOENT panic. /nix/store paths work on the
# host AND inside the container (which only mounts /nix).
set -gx NIX_LD /nix/store/w59civhx8gfi5w00qz6xrv951s13kf7g-nix-ld-libraries/share/nix-ld/lib/ld.so
set -gx NIX_LD_LIBRARY_PATH /nix/store/w59civhx8gfi5w00qz6xrv951s13kf7g-nix-ld-libraries/share/nix-ld/lib

# Apply the system config (system + home). Only for Nix packages, services,
# drivers, modules, or system configuration. Dotfile edits are already live.
function rebuild
    nh os switch
end

# Update Nix inputs (nixpkgs, home-manager, caelestia-shell, kernel) and
# rebuild. Does not touch ~/dotfiles.
function update
    cd ~/nix-config
    or return 1

    nix flake update
    or return 1

    nh os switch
end

# Pull upstream Caelestia config changes (git fetch + merge; no resets,
# no discarding conflicts).
function dots-update
    cd ~/dotfiles
    or return 1

    if not git diff --quiet
        echo "dotfiles has uncommitted changes; commit or stash them first"
        return 1
    end

    if not git diff --cached --quiet
        echo "dotfiles has staged changes; commit or stash them first"
        return 1
    end

    git fetch upstream
    or return 1

    git merge upstream/main
    or begin
        echo "merge needs attention; resolve the conflicts in ~/dotfiles"
        return 1
    end

    echo "Caelestia dots updated. Run hyprctl reload and restart the shell."
end

# Commit + push snapshots of the nix config and the dotfiles, separately.
function save
    for repo in ~/nix-config ~/dotfiles
        if not test -d "$repo/.git"
            echo "skip: $repo is not a git repository"
            continue
        end

        echo "==> saving $repo"

        git -C "$repo" add -A
        or begin
            echo "failed to stage changes in $repo"
            return 1
        end

        if git -C "$repo" diff --cached --quiet
            echo "    nothing new — skipping commit"
            continue
        end

        set -l msg "update "(date +%F\ %H:%M | string join ' ')
        git -C "$repo" commit -m "$msg"
        or begin
            echo "commit failed in $repo"
            return 1
        end

        if git -C "$repo" remote | grep -q .
            git -C "$repo" push
            or echo "    committed, but push failed"
        else
            echo "    no remote — committed locally, skipped push"
        end
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
