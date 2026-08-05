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
