#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

install_tv="ask"
shell_choice="ask"

while [ $# -gt 0 ]; do
  case "$1" in
    --with-tv)
      install_tv="yes"
      ;;
    --without-tv)
      install_tv="no"
      ;;
    --shell)
      shift
      if [ $# -eq 0 ]; then
        echo "--shell requires a value: zsh or nu" >&2
        exit 1
      fi
      shell_choice="$1"
      ;;
    --shell=*)
      shell_choice="${1#*=}"
      ;;
    --zsh)
      shell_choice="zsh"
      ;;
    --nu|--nushell)
      shell_choice="nu"
      ;;
    -h|--help)
      cat <<'EOF'
Usage: ./setup.sh [--shell zsh|nu] [--with-tv|--without-tv]

  --shell zsh|nu  Choose the shell profile to install (default: zsh)
  --with-tv     Install and link Television (tv) without prompting
  --without-tv  Skip Television (tv) without prompting
EOF
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
  shift
done

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required. Install it first: https://brew.sh"
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required to generate themed config files."
  exit 1
fi

mkdir -p "$HOME/.config" "$HOME/.cache/zsh" "$HOME/.local/state/zsh"

if [ "$shell_choice" = "ask" ]; then
  if [ -t 0 ]; then
    printf "Choose shell profile [zsh/nu] (default: zsh): "
    read -r reply
    case "$reply" in
      ""|zsh|ZSH)
        shell_choice="zsh"
        ;;
      nu|NU|nushell|NUSHELL)
        shell_choice="nu"
        ;;
      *)
        echo "Unsupported shell: $reply" >&2
        exit 1
        ;;
    esac
  else
    shell_choice="zsh"
  fi
fi

case "$shell_choice" in
  zsh|nu)
    ;;
  *)
    echo "Unsupported shell: $shell_choice" >&2
    exit 1
    ;;
esac

if [ "$install_tv" = "ask" ]; then
  if [ -t 0 ]; then
    printf "Install Television (tv) fuzzy picker UI? [y/N] "
    read -r reply
    case "$reply" in
      y|Y|yes|YES)
        install_tv="yes"
        ;;
      *)
        install_tv="no"
        ;;
    esac
  else
    install_tv="no"
  fi
fi

python3 scripts/apply_theme.py

brew bundle --file Brewfile

packages=(ghostty starship tmux nvim)

if [ "$shell_choice" = "zsh" ]; then
  brew bundle --file Brewfile.zsh
  packages+=(zsh)
  stow -D -t "$HOME" nushell || true
else
  brew bundle --file Brewfile.nu
  packages+=(nushell)
  stow -D -t "$HOME" zsh || true
fi

if [ "$install_tv" = "yes" ]; then
  brew bundle --file Brewfile.tv
  packages+=(television)
  if [ "$shell_choice" = "nu" ]; then
    packages+=(television-nu)
  else
    stow -D -t "$HOME" television-nu || true
  fi
else
  stow -D -t "$HOME" television || true
  stow -D -t "$HOME" television-nu || true
fi

stow -t "$HOME" "${packages[@]}"

if command -v git >/dev/null 2>&1; then
  TMUX_PLUGIN_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/tmux/plugins"
  TPM_DIR="$TMUX_PLUGIN_DIR/tpm"
  if [ ! -d "$TPM_DIR" ]; then
    mkdir -p "$TMUX_PLUGIN_DIR"
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
  fi
  if [ -x "$TPM_DIR/bin/install_plugins" ]; then
    tmux start-server >/dev/null 2>&1 || true
    tmux source-file "$HOME/.config/tmux/tmux.conf" >/dev/null 2>&1 || true
    "$TPM_DIR/bin/install_plugins" || true
  fi
fi
