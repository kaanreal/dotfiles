# kaan's Arch fish config
#
# Managed in the repo at ~/cozy-home/devices/linux/setup/fish/config.fish.
# To edit, change it there and run devices/linux/setup.sh again — this
# file is a copy, and the copy is overwritten on re-setup.

# --- prompt ---------------------------------------------------------------
starship init fish | source

# --- fzf / zoxide ---------------------------------------------------------
fzf --fish | source
zoxide init fish | source

# --- PATH -----------------------------------------------------------------
fish_add_path ~/.local/bin

# --- aliases --------------------------------------------------------------
alias ls='eza --group-directories-first'
alias ll='eza -lah --group-directories-first --git'
alias tree='eza --tree --group-directories-first'
alias grep='rg'
alias cat='bat'
alias du='duf' 2>/dev/null
alias up='sudo pacman -Syu'
alias in='sudo pacman -S'
alias un='sudo pacman -Rns'
alias se='pacman -Ss'
alias orphans='sudo pacman -Rns (pacman -Qtdq)'
alias dots='cd $HOME/cozy-home'

# --- greeting -------------------------------------------------------------
# Adaptive fastfetch: shrink the logo so it always fits the window.
function fastfetch
    set -l cols 80
    if command stty size >/dev/null 2>&1
        set cols (string split ' ' (stty size))[2]
    end
    set -l w 45
    if test $cols -lt 90;  set w 32; end
    if test $cols -lt 72;  set w 24; end
    if test $cols -lt 55;  set w 16; end
    command fastfetch --logo-width $w $argv
end

function fish_greeting
    command -v fastfetch &> /dev/null && fastfetch
end

# --- dotfiles backup ------------------------------------------------------
# Snapshots ~/cozy-home (dots + Arch config included) to git + pushes.
# Same flow as the NixOS side (save): full snapshot each time.
function dotpush
    set -l repo $HOME/cozy-home
    test -d $repo || begin; echo "no cozy-home repo found"; return 1; end

    git -C $repo add -A || return 1

    set -l emojis '🌼' '🌙' '🍃' '🧁' '🌷' '🫧' '☕' '🧸' '🍓' '🐈'
    set -l emoji $emojis[(random 1 (count $emojis))]
    set -l msg "$emoji "(date '+%F %H:%M:%S')
    set -l body (git -C $repo diff --cached --stat | string join \n)

    if test -z "$body"
        echo "nothing to commit — config already saved"
        return 0
    end

    git -C $repo commit -m "$msg" -m "$body"
    if git -C $repo remote | grep -q .
        git -C $repo push
        or echo "committed locally, but push failed"
    else
        echo "no git remote set — committed locally, skipped push"
    end
end
