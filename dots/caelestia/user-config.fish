# Caelestia user fish config for Linux, on top of the shared
# fish config in dots/fish. Sourced from ~/.config/caelestia/user-config.fish
# on every new shell.
#
# Shared commands (save, dots-update, fish_greeting, fastfetch) live in
# dots/fish/functions/ and are shared with macOS.

# User-installed scripts (e.g. osu-wine from osu-winello).
set -gx PATH $HOME/.local/bin $PATH

if test -e /etc/NIXOS
    # nh >= 4.4 no longer detects the flake from the current directory.
    set -gx NH_OS_FLAKE $HOME/dotfiles

    function rebuild
        nh os switch "path:$HOME/dotfiles"
    end

    function update
        nix flake update --flake $HOME/dotfiles
        or return 1
        nh os switch "path:$HOME/dotfiles"
    end

    function cleanup
        nh clean all
        echo "cleaned up old generations"
    end
else if test -e /etc/arch-release
    function update
        if command -q yay
            yay -Syu
        else
            sudo pacman -Syu
        end
    end

    function cleanup
        set -l orphans (pacman -Qtdq)
        test -z "$orphans"; or sudo pacman -Rns $orphans
        sudo paccache -rk2
    end
end
