# Dotfiles

Personal macOS dotfiles built around Ghostty, tmux, Starship, mise, and LazyVim. The repo is designed to be enough by itself to reproduce the current terminal setup on a new Mac.

## What This Sets Up

- `Ghostty` as the primary terminal.
- `tmux` with a top status bar, pill-style theme, TPM plugins, SessionX, Floax, tmux-fzf, URL picker, resurrect, and continuum restore disabled by default.
- `zsh` by default, with optional `nushell` profile support.
- `Starship` prompt with directory/git on the left, mise runtime tools and command status on the first-line right side, and contextual right prompt modules on the input line.
- `tmux` running-command spinner in the status bar for zsh commands that last longer than 500ms.
- `mise` as the single runtime manager for Python, Node, Java, and other project-local tool versions.
- `LazyVim` replacing SpaceVim, with transparent theme support and tmux navigator integration.
- Optional `television` (`tv`) fuzzy picker UI with file, git, Docker, Kubernetes, GitHub, history, tmux, and utility channels.
- CLI utilities: `atuin`, `bat`, `direnv`, `eza`, `fd`, `fzf`, `gh`, `git`, `jq`, `kubectl`, `lazygit`, `rg`, `yazi`, `yq`, and `zoxide`.

## Requirements

- macOS.
- Homebrew installed before running setup.
- This repo cloned to `~/dotfiles`.
- Existing dotfiles moved out of the way if they conflict with GNU Stow links.

Clone location matters because a few defaults point at `~/dotfiles`, especially tmux SessionX custom paths.

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
```

## Install

Interactive install, defaulting to `zsh` and asking whether to install `tv`:

```bash
./setup.sh
```

Non-interactive examples:

```bash
./setup.sh --shell zsh --with-tv
./setup.sh --shell zsh --without-tv
./setup.sh --shell nu --with-tv
./setup.sh --shell nu --without-tv
```

`setup.sh` performs these steps:

- Generates theme-derived configs from `theme/theme.toml`.
- Runs `brew bundle --file Brewfile`.
- Installs shell-specific packages from `Brewfile.zsh` or `Brewfile.nu`.
- Optionally installs `television` from `Brewfile.tv`.
- Uses `stow` to link only the selected shell profile plus common app configs into `$HOME`.
- Installs TPM under `~/.local/share/tmux/plugins/tpm` if missing.
- Attempts to install tmux plugins after linking the tmux config.

## Repo Layout

- `Brewfile`: common Homebrew formulae and casks.
- `Brewfile.zsh`: zsh and zsh plugins.
- `Brewfile.nu`: nushell.
- `Brewfile.tv`: optional Television package.
- `setup.sh`: main bootstrap entrypoint.
- `theme/theme.toml`: shared theme token source.
- `scripts/apply_theme.py`: generator for Ghostty, tmux, Neovim, and Television theme files.
- `ghostty/`: `~/.config/ghostty/config`.
- `zsh/`: `~/.zshenv`, `~/.config/zsh/.zprofile`, and `~/.config/zsh/.zshrc`.
- `nushell/`: `~/.config/nushell/env.nu` and `~/.config/nushell/config.nu`.
- `starship/`: prompt config and the custom mise runtime module.
- `tmux/`: tmux config, generated theme, reset config, and small helper scripts.
- `nvim/`: LazyVim-based Neovim config.
- `television/`: optional Television config and channel library.
- `television-nu/`: extra Television channel for Nushell history.
- `examples/`: small project-local examples, including mise runtime config.
- `KEYMAPS.md`: all configured shortcuts and important tool combinations.

## Shell Profiles

The default profile is `zsh`.

`zsh` layout:

- `~/.zshenv`: XDG paths and `ZDOTDIR`.
- `~/.config/zsh/.zprofile`: Homebrew path, editor, pager, local bin.
- `~/.config/zsh/.zshrc`: completion, fzf, zsh plugins, aliases, mise, zoxide, atuin, direnv, optional tv, and Starship.
- `~/.config/zsh/command-spinner-excludes`: editable zsh patterns for commands that should not show the tmux running-command spinner.

`nushell` layout:

- `~/.config/nushell/env.nu`: XDG paths, Homebrew path, editor, generated init caches.
- `~/.config/nushell/config.nu`: aliases, direnv hook, zoxide, atuin, Starship, mise, and optional tv keybindings.

Ghostty uses `shell-integration = detect` so the terminal is not hard-coded to zsh when the Nushell profile is selected.

## Theme System

Theme values are centralized in `theme/theme.toml`. App configs are generated from token sets instead of manually duplicating colors.

Generated files:

- `ghostty/.config/ghostty/config`
- `tmux/.config/tmux/theme.conf`
- `nvim/.config/nvim/lua/config/theme.lua`
- `television/.config/television/config.toml` generated block

Commands:

```bash
cd ~/dotfiles
python3 scripts/apply_theme.py --list
python3 scripts/apply_theme.py --set mocha
python3 scripts/apply_theme.py --set tokyonight
python3 scripts/apply_theme.py --set storm
python3 scripts/apply_theme.py --set moon
python3 scripts/apply_theme.py --reset
```

After changing tmux theme output:

```bash
tmux source-file ~/.config/tmux/tmux.conf
```

Ghostty does not continuously watch this repo. Restart Ghostty or reload its config after generated Ghostty changes.

## Runtime Versions With mise

Use project-local `mise.toml` files instead of global pyenv/fnm state.

Example:

```toml
[tools]
python = "3.12"
node = "22"
java = "temurin-21"
```

Apply in a project:

```bash
cp ~/dotfiles/examples/mise/python-node-java.toml ./mise.toml
mise trust
mise install
mise current
```

The Starship runtime segment only displays tools that are both active in the current directory and actually installed. Missing tools from `mise.toml` are intentionally hidden until installed.

## Television

`tv` is optional because it adds a large picker/channel surface. Install it with `--with-tv`.

When installed:

- `Ctrl+t` opens smart autocomplete through Television.
- `Ctrl+g` opens Television-backed command history.
- `Ctrl+r` remains Atuin history in zsh.
- `tv` by itself opens the default `files` channel.

The preview panel is enabled in `television/.config/television/config.toml`. The theme override uses a transparent background so it visually inherits Ghostty/tmux instead of double-darkening the UI.

## Updating

Install newly added packages:

```bash
brew bundle --file Brewfile
brew bundle --file Brewfile.zsh
brew bundle --file Brewfile.tv
```

Re-link dotfiles:

```bash
stow -t "$HOME" ghostty starship tmux nvim zsh
```

Use `nushell` instead of `zsh`:

```bash
stow -D -t "$HOME" zsh
stow -t "$HOME" nushell
```

## Validation Commands

These are the checks used to keep the repo sane:

```bash
bash -n setup.sh
zsh -n zsh/.zshenv zsh/.config/zsh/.zprofile zsh/.config/zsh/.zshrc
sh -n starship/.config/starship/scripts/mise-tools.sh tmux/.config/tmux/apply-theme.sh tmux/.config/tmux/scripts/current-path.sh
python3 -m py_compile scripts/apply_theme.py
python3 scripts/apply_theme.py
STARSHIP_CONFIG="$PWD/starship/.config/starship/starship.toml" starship prompt --status 0 --cmd-duration 1200 --terminal-width 120
tmux -f tmux/.config/tmux/tmux.conf start-server
```

If a generated file changes after `python3 scripts/apply_theme.py`, commit both `theme/theme.toml` and the generated output so a fresh clone matches the current live setup.
