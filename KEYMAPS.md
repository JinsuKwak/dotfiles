# Keymaps And Tool Combinations

This document lists the shortcuts configured by this dotfiles repo. Defaults supplied by plugins are included only when they materially affect the workflow.

## Recommended Terminal Shape

```text
Ghostty
  -> tmux session: dev
    -> window 1: local
    -> window 2: nvim
    -> window 3: ssh
    -> window 4: ai
    -> window 5: logs
```

Create it manually:

```bash
tmux new -s dev
tmux rename-window -t 1 local
tmux new-window -n nvim
tmux new-window -n ssh
tmux new-window -n ai
tmux new-window -n logs
```

For nested remote tmux, keep local tmux on `Ctrl+a` and use remote tmux's default `Ctrl+b` to avoid prefix conflicts.

## Ghostty

| Action | Key |
| --- | --- |
| New tab | `Cmd+t` |
| Close surface | `Cmd+w` |
| Toggle fullscreen | `Cmd+Enter` |
| Toggle global quick terminal | `Cmd+\`` |

Ghostty does not take `Ctrl+a`; tmux owns that prefix.

## zsh

| Action | Key or command |
| --- | --- |
| Prompt | Starship |
| Autosuggestions | zsh-autosuggestions |
| Syntax highlighting | zsh-syntax-highlighting |
| Completion menu | zsh completion system |
| fzf file picker, when tv is not installed | `Ctrl+t` |
| fzf directory jump | `Alt+c` |
| Atuin history | `Ctrl+r` |
| Television smart autocomplete, when tv is installed | `Ctrl+t` |
| Television command history, when tv is installed | `Ctrl+g` |
| zoxide jump | `z <query>` |
| mise runtime activation | automatic on directory change |
| direnv activation | automatic when `.envrc` is allowed |

Configured aliases:

| Alias | Expands to |
| --- | --- |
| `v`, `vi`, `vim` | `nvim` |
| `..` | `cd ..` |
| `...` | `cd ../..` |
| `gst` | `git status -sb` |
| `ga` | `git add` |
| `gc` | `git commit` |
| `gco` | `git checkout` |
| `gpl` | `git pull --rebase --autostash` |
| `gps` | `git push` |
| `gl` | `git log --oneline --graph --decorate -20` |
| `k` | `kubectl` |
| `kgp` | `kubectl get pods` |
| `kgs` | `kubectl get svc` |
| `cat` | `bat --paging=never --style=plain`, only if `bat` exists |
| `ls` | `eza --icons=auto`, only if `eza` exists |
| `ll` | `eza -lh --git --icons=auto`, only if `eza` exists |
| `la` | `eza -lah --git --icons=auto`, only if `eza` exists |
| `lt` | `eza --tree --level=2 --icons=auto`, only if `eza` exists |

## Nushell

| Action | Key or command |
| --- | --- |
| Prompt | Starship |
| zoxide jump | `z <query>` |
| Atuin history | Atuin Nushell integration |
| mise runtime activation | generated Nushell init |
| direnv activation | pre-prompt hook |
| Television smart autocomplete, when tv is installed | `Ctrl+t` |
| Television command history, when tv is installed | `Ctrl+g` |

Configured aliases:

| Alias | Expands to |
| --- | --- |
| `v`, `vi`, `vim` | `nvim` |
| `gst` | `git status -sb` |
| `ga` | `git add` |
| `gc` | `git commit` |
| `gco` | `git checkout` |
| `gps` | `git push` |
| `gl` | `git log --oneline --graph --decorate -20` |
| `k` | `kubectl` |
| `kgp` | `kubectl get pods` |
| `kgs` | `kubectl get svc` |

## Starship Prompt

| Area | Content |
| --- | --- |
| First line left | Directory, git branch, git status |
| First line right | Active installed mise tools, command status icon |
| Input line left | `➜` prompt character |
| Input line right | AWS profile, Kubernetes context, command duration |

Runtime tools are rendered by `starship/.config/starship/scripts/mise-tools.sh`. It reads `mise ls --current`, skips `(missing)` tools, and displays known language/tool icons.

## tmux Core

| Action | Key |
| --- | --- |
| Prefix | `Ctrl+a` |
| Send literal prefix | `Ctrl+a` then `Ctrl+a` |
| Horizontal split | `Ctrl+a` then `\|`, `\`, or `v` |
| Vertical split | `Ctrl+a` then `-` |
| Temporary Yazi file manager pane | `Ctrl+a` then `Tab` |
| Move pane left/down/up/right | `Ctrl+a` then `h/j/k/l` |
| Resize pane left/down/up/right | `Ctrl+a` then `Shift+h/j/k/l` |
| New window | `Ctrl+a` then `c` |
| Next window | `Ctrl+a` then `n` |
| Previous window | `Ctrl+a` then `p` |
| Choose sessions/tree | `Ctrl+a` then `s` |
| Kill pane | `Ctrl+a` then `x` |
| Kill window | `Ctrl+a` then `X` |
| Reload tmux config | `Ctrl+a` then `r` |
| Enter copy mode | `Ctrl+a` then `[` |
| Start selection in copy mode | `v` |
| Copy selection to macOS clipboard | `y` |

Mouse support is enabled. Window and pane indexes start at `1`.

## tmux And Neovim Navigation

| Action | Key |
| --- | --- |
| Move left | `Ctrl+h` |
| Move down | `Ctrl+j` |
| Move up | `Ctrl+k` |
| Move right | `Ctrl+l` |

When the active pane is Neovim, these keys are sent into Neovim first through `vim-tmux-navigator`. At the Neovim split edge, the same keys move to the surrounding tmux pane.

## tmux Plugins

| Plugin | Action | Key |
| --- | --- | --- |
| TPM | Install plugins | `Ctrl+a` then `I` |
| TPM | Update plugins | `Ctrl+a` then `U` |
| TPM | Remove unlisted plugins | `Ctrl+a` then `Alt+u` |
| tmux-sessionx | Session/project picker | `Ctrl+a` then `o` |
| tmux-sessionx | Tree mode inside picker | `Ctrl+t` |
| tmux-sessionx | Window mode inside picker | `Ctrl+w` |
| tmux-sessionx | New window inside picker | `Ctrl+e` |
| tmux-sessionx | Open zoxide result as new window | `Ctrl+y` |
| tmux-sessionx | Rename session inside picker | `Ctrl+r` |
| tmux-floax | Toggle floating pane | `Ctrl+a` then `P` |
| tmux-floax | Floating pane menu | `Ctrl+a` then `M` |
| tmux-fzf | tmux object picker | `Ctrl+a` then `F` |
| tmux-fzf-url | URL picker | `Ctrl+a` then `u` |
| tmux-yank | Copy current line | `Ctrl+a` then `y` |
| tmux-yank | Copy pane current path | `Ctrl+a` then `Y` |
| tmux-resurrect | Save session | `Ctrl+a` then `Ctrl+s` |
| tmux-resurrect | Restore session | `Ctrl+a` then `Ctrl+r` |

`tmux-continuum` is installed, but automatic restore is disabled with `@continuum-restore "off"`.

## Neovim / LazyVim

| Action | Key |
| --- | --- |
| Leader | `Space` |
| Local leader | `\` |
| Leave insert mode | `jj` or `jk` |
| tmux/Neovim pane navigation | `Ctrl+h/j/k/l` |

LazyVim keeps its default keymaps. This repo only adds the insert-mode escape shortcuts, transparent theme support, custom formatter/LSP/tool defaults, and tmux navigator integration.

Configured editor tooling:

| Area | Tools |
| --- | --- |
| Treesitter parsers | Bash, diff, HTML, JavaScript, JSON, Lua, Markdown, Python, regex, TOML, TSX, TypeScript, Vim, YAML |
| Mason tools | bash-language-server, json-lsp, lua-language-server, marksman, prettier, pyright, ruff, shfmt, stylua, yaml-language-server, yamlfmt |
| Formatters | Stylua for Lua, Ruff for Python, shfmt for shell, yamlfmt for YAML |
| LSP servers | bashls, jsonls, pyright, ruff, yamlls |

## Television

Television is optional. It is linked only when setup is run with `--with-tv` or when confirmed interactively.

| Action | Key |
| --- | --- |
| Quit | `Esc` or `Ctrl+c` |
| Move down/up | `Down`/`Up`, `Ctrl+n`/`Ctrl+p`, or `Ctrl+j`/`Ctrl+k` |
| Confirm selection | `Enter` |
| Multi-select down/up | `Tab` / `Shift+Tab` |
| Copy entry to clipboard | `Ctrl+y` |
| Cycle sources | `Ctrl+s` |
| Toggle remote control | `Ctrl+r` |
| Toggle action picker | `Ctrl+x` |
| Toggle preview | `Ctrl+o` |
| Scroll preview | `Ctrl+d` / `Ctrl+u` |
| Cycle preview mode | `Ctrl+f` |
| Toggle help | `F9` |
| Toggle status bar | `F10` |
| Toggle layout | `Ctrl+t` |
| Delete previous word in input | `Ctrl+w` |

Important shell integration triggers:

| Shell command prefix | Television channel |
| --- | --- |
| `cd`, `ls`, `rmdir`, `z` | `dirs` |
| `cat`, `less`, `vim`, `bat`, `cp`, `mv`, `rm`, `touch`, archives | `files` |
| `git checkout`, `git branch`, `git merge`, `git rebase`, `git pull`, `git push` | `git-branch` |
| `git add`, `git restore` | `git-diff` |
| `git log`, `git show` | `git-log` |
| `docker run` | `docker-images` |
| `nvim`, `code`, `hx`, `git clone` | `git-repos` |
| `alias`, `unalias` | `alias` |
| `export`, `unset` | `env` |

Configured channel library includes files, directories, git, Docker, Kubernetes, GitHub issues/PRs, Homebrew packages, npm packages/scripts, Python venvs, tmux sessions/windows, SSH hosts, processes, Unicode, and shell history channels.

## mise

| Action | Command |
| --- | --- |
| Trust project config | `mise trust` |
| Install project tools | `mise install` |
| Show active tools | `mise current` |
| Show installed/current state | `mise ls --current` |
| Add tool to project | `mise use python@3.12` |
| Remove installed tool | `mise uninstall python@3.12.13` |

If `mise ls --current` shows `(missing)`, the project config still requests that runtime but the runtime is not installed.
