#!/usr/bin/env sh

pane="${1:-}"

[ -n "$pane" ] || exit 0

current_command="$(tmux display-message -pt "$pane" "#{pane_current_command}" 2>/dev/null || true)"

case "$current_command" in
  zsh|-zsh|bash|-bash|sh|-sh|fish|-fish|nu|-nu|tmux)
    tmux set-option -pqt "$pane" @pane_command_spinner "" >/dev/null 2>&1
    ;;
esac
