# Pull upstream Caelestia config changes into dots/ (vendored subtree).
# git fetch + subtree pull; no resets, no discarding conflicts.
# Works on any OS — shared with NixOS.
function dots-update
    set -l repo $HOME/dotfiles

    if not test -d $repo/.git
        echo "~/dotfiles is not a git repository"
        return 1
    end

    set -l changes (git -C $repo status --porcelain | string collect)
    if test -n "$changes"
        echo "dotfiles is not clean; commit or stash changes first"
        return 1
    end

    git -C $repo fetch caelestia-upstream
    or return 1

    git -C $repo subtree pull --prefix dots caelestia-upstream main
    or begin
        echo "merge needs attention; resolve the conflicts in ~/dotfiles/dots"
        return 1
    end

    echo "Caelestia dots updated. Restart the shell (and hyprctl reload on Hyprland)."
end
