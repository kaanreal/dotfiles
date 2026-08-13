# macOS-only additions, sourced automatically by fish (conf.d) on Darwin.

if status is-interactive
    test (uname) = Darwin || return

    # Homebrew environment (kept absolute so it works in any fish).
    /opt/homebrew/bin/brew shellenv | source

    # User scripts
    fish_add_path $HOME/.local/bin

    # Prefer the same tools as everywhere else
    alias grep='rg'
    alias cat='bat'

    # brew helpers
    abbr up 'brew upgrade && brew cleanup'
    abbr in 'brew install'
    abbr un 'brew uninstall'
    abbr se 'brew search'

    # clear + fastfetch
    function clearfetch
        clear
        fastfetch
    end
end
