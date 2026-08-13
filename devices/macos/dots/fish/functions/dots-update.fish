# Pull upstream Caelestia config changes into dots/ (vendored subtree).
# git fetch + subtree pull; no resets, no discarding conflicts.
# Works on any OS — shared with NixOS.
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

    echo "Caelestia dots updated. Restart the shell (and hyprctl reload on Hyprland)."
end
