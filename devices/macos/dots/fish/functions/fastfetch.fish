# Adaptive fastfetch: shrink the logo so it always fits the window.
# The Apple logo is taller than a typical banner, so macOS uses smaller widths.
# function <name> shadows the real binary, `command fastfetch` bypasses it.
function fastfetch
    set -l cols 80
    if command stty size >/dev/null 2>&1
        set cols (string split ' ' (stty size))[2]
    end
    set -l w 28
    if test $cols -lt 90
        set w 24
    end
    if test $cols -lt 72
        set w 18
    end
    if test $cols -lt 55
        set w 12
    end
    command fastfetch --logo-width $w $argv
end
