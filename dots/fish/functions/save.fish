# Commit + push a snapshot of ~/dotfiles (no empty commits, no force-push).
# Works on any OS and is shared with NixOS.
function save
    set -l repo $HOME/dotfiles

    if not test -d $repo/.git
        echo "skip: ~/dotfiles is not a git repository"
        return 1
    end

    echo "==> saving ~/dotfiles"

    if git -C $repo remote get-url origin >/dev/null 2>&1
        git -C $repo fetch origin
        or begin
            echo "fetch failed; nothing was staged or committed"
            return 1
        end

        set -l branch (git -C $repo branch --show-current)
        if test -z "$branch"
            echo "refusing to save from a detached HEAD"
            return 1
        end

        set -l upstream origin/$branch
        if not git -C $repo rev-parse --verify $upstream >/dev/null 2>&1
            echo "missing upstream branch: $upstream"
            return 1
        end

        set -l counts (git -C $repo rev-list --left-right --count HEAD...$upstream | string split \t)
        if test $counts[2] -ne 0
            echo "remote has $counts[2] commit(s) this checkout does not have"
            echo "pull and resolve that first; nothing was staged or committed"
            return 1
        end
    end

    git -C $repo add -A
    or begin
        echo "failed to stage changes"
        return 1
    end

    if git -C $repo diff --cached --quiet
        echo "    nothing new; skipping commit"
        return 0
    end

    set -l emojis '🌸' '🌷' '🍃' '🧁' '🐰' '❄️' '🧸' '🍓' '🐈'
    set -l emoji $emojis[(random 1 (count $emojis))]
    set -l msg "$emoji "(date '+%F %H:%M:%S')
    git -C $repo commit -m "$msg"
    or begin
        echo "commit failed"
        return 1
    end

    if git -C $repo remote get-url origin >/dev/null 2>&1
        git -C $repo push origin
        or begin
            echo "    committed locally, but push failed"
            return 1
        end
    else
        echo "    no remote; committed locally, skipped push"
    end
end
