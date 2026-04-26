#!/usr/bin/env sh

pane="${1:-}"
gap="${2:- }"
spinner_fg="${3:-}"
text_fg="${4:-}"
padding="${5:- }"

[ -n "$pane" ] || exit 0

spinner="$(tmux show-options -p -t "$pane" -qv @pane_command_spinner 2>/dev/null || true)"

if [ -z "$spinner" ]; then
  printf "%s" "$padding"
  exit 0
fi

printf "%s#[bg=default]#[fg=%s]%s#[fg=%s]#[bg=default]%s" \
  "$gap" "$spinner_fg" "$spinner" "$text_fg" "$padding"
