#!/usr/bin/env sh

pane="${1:-}"

[ -n "$pane" ] || exit 0

current_command="$(tmux display-message -pt "$pane" "#{pane_current_command}" 2>/dev/null || true)"

case "$current_command" in
  zsh|-zsh|bash|-bash|sh|-sh|fish|-fish|nu|-nu|tmux|tv|fzf|k9s|nvim|vim|vi|yazi|lazygit|less|more|man|ssh|top|htop|btop|watch|tail)
    tmux set-option -pqt "$pane" @pane_command_spinner "" >/dev/null 2>&1
    ;;
esac
