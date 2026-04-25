setopt auto_cd interactive_comments prompt_subst
setopt hist_ignore_all_dups share_history

zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}'
zstyle ':completion:*' menu select

HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
HISTSIZE=100000
SAVEHIST=100000

mkdir -p "${HISTFILE:h}" "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"

if command -v brew >/dev/null 2>&1; then
  BREW_PREFIX="$(brew --prefix)"
  FPATH="$BREW_PREFIX/share/zsh/site-functions:$FPATH"
fi

autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"

if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh)
  compdef _kubectl k
fi

if [ -n "${BREW_PREFIX:-}" ] && [ -d "$BREW_PREFIX/opt/fzf/shell" ]; then
  [ -f "$BREW_PREFIX/opt/fzf/shell/completion.zsh" ] && source "$BREW_PREFIX/opt/fzf/shell/completion.zsh"
  [ -f "$BREW_PREFIX/opt/fzf/shell/key-bindings.zsh" ] && source "$BREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
fi

if [ -n "${BREW_PREFIX:-}" ] && [ -f "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

if [ -n "${BREW_PREFIX:-}" ] && [ -f "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship/starship.toml"

if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
else
  export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/.git/*"'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='find . -type d -not -path "*/.git/*"'
fi

alias vim="nvim"
alias vi="nvim"
alias v="nvim"
alias ..="cd .."
alias ...="cd ../.."
alias gst="git status -sb"
alias ga="git add"
alias gc="git commit"
alias gco="git checkout"
alias gpl="git pull --rebase --autostash"
alias gps="git push"
alias gl="git log --oneline --graph --decorate -20"
alias k="kubectl"
alias kgp="kubectl get pods"
alias kgs="kubectl get svc"

if command -v bat >/dev/null 2>&1; then
  alias cat="bat --paging=never --style=plain"
fi

if command -v eza >/dev/null 2>&1; then
  alias ls="eza --icons=auto"
  alias ll="eza -lh --git --icons=auto"
  alias la="eza -lah --git --icons=auto"
  alias lt="eza --tree --level=2 --icons=auto"
fi

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh)"
fi

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

if command -v tv >/dev/null 2>&1 && [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/television/config.toml" ]; then
  eval "$(tv init zsh)"
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

unset BREW_PREFIX
