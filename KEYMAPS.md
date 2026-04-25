# Keymaps

## Stack

```text
Ghostty
  -> tmux
    -> window 1: local dev
    -> window 2: nvim / LazyVim
    -> window 3: ssh remote
    -> window 4: AI CLI
    -> window 5: logs / server
```

## Ghostty

| Action | Key |
| --- | --- |
| New tab | `Cmd+t` |
| Close surface | `Cmd+w` |
| Fullscreen | `Cmd+Enter` |
| Quick terminal | `Cmd+\`` |

Ghostty does not remap `Ctrl+a`; tmux owns that prefix.

## tmux

| Action | Key |
| --- | --- |
| Prefix | `Ctrl+a` |
| Horizontal split | `Ctrl+a` then `|`, `\`, or `v` |
| Vertical split | `Ctrl+a` then `-` |
| Move pane | `Ctrl+a` then `h/j/k/l` |
| Resize pane | `Ctrl+a` then `Shift+h/j/k/l` |
| New window | `Ctrl+a` then `c` |
| Next window | `Ctrl+a` then `n` |
| Previous window | `Ctrl+a` then `p` |
| Session picker | `Ctrl+a` then `s` |
| Kill pane | `Ctrl+a` then `x` |
| Kill window | `Ctrl+a` then `X` |
| Reload config | `Ctrl+a` then `r` |
| SessionX | `Ctrl+a` then `o` |
| Floax | `Ctrl+a` then `P` |

## nvim And tmux

| Action | Key |
| --- | --- |
| Move left | `Ctrl+h` |
| Move down | `Ctrl+j` |
| Move up | `Ctrl+k` |
| Move right | `Ctrl+l` |

These keys move between Neovim splits first. When the edge of Neovim is reached, the same keys move to the surrounding tmux pane.

## Recommended Windows

| Window | Name | Use |
| --- | --- | --- |
| `1` | `local` | Local shell and dev commands |
| `2` | `nvim` | LazyVim |
| `3` | `ssh` | Remote shell |
| `4` | `ai` | Codex, Claude, Gemini, or other AI CLI |
| `5` | `logs` | Server logs and long-running processes |

Create this shape manually:

```bash
tmux new -s dev
tmux rename-window -t 1 local
tmux new-window -n nvim
tmux new-window -n ssh
tmux new-window -n ai
tmux new-window -n logs
```

For remote work, keep local tmux at `Ctrl+a` and remote tmux at `Ctrl+b` to avoid nested prefix conflicts.
