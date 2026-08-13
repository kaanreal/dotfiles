# fish colors for machines without a Caelestia shell (macOS, Arch…).
# On NixOS the caelestia daemon prints its palette into
# ~/.local/state/caelestia/sequences.txt, which overrides these.
#
# Hex colors are quoted — fish treats a bare `#abc` as a comment.

if status is-interactive
    if not test -f ~/.local/state/caelestia/sequences.txt
        # beige theme
        set -g fish_color_normal "#d4a96a"
        set -g fish_color_command "#d4a96a"
        set -g fish_color_param "#d4a96a"
        set -g fish_color_error "#d4a96a"
        set -g fish_color_quote "#7db87d"
        set -g fish_color_redirection "#7a9ec2"
        set -g fish_color_end "#9a9389"
        set -g fish_color_comment "#9a9389"
        set -g fish_color_selection --background="#332C25" --foreground="#e8e6e3"
        set -g fish_color_search_match --background="#332C25" --foreground="#d4a96a"
        set -g fish_color_autosuggestion --dim "#4a453b"
        set -g fish_color_cancel "#C15F3C"
        set -g fish_color_escape "#6eb8b8"
        set -g fish_pager_color_progress bold "#C15F3C"
        set -g fish_pager_color_prefix bold --background="#1a1f1f" --foreground="#d4a96a"
        set -g fish_pager_color_completion bold --background="#1a1f1f" --foreground="#d4a96a"
        set -g fish_pager_color_description bold --background="#1a1f1f" --foreground="#9a9389"
        set -g fish_pager_color_selected_background --background="#C15F3C" --foreground="#0a0f0f"
        set -g fish_pager_color_selected_prefix bold --background="#C15F3C" --foreground="#0a0f0f"
        set -g fish_pager_color_selected_completion bold --background="#C15F3C" --foreground="#0a0f0f"
        set -g fish_pager_color_selected_description bold --background="#C15F3C" --foreground="#e8e6e3"
        set -g fish_pager_color_secondary_background --background="#1a1f1f"
    end
end