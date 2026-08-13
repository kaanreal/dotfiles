# Commit + push a snapshot of ~/cozy-home (no empty commits, no force-push).
# Works on any OS — shared with NixOS.
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
