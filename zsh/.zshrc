## ~/.zshrc — OS-agnostic base with core features
# Keep platform-specific exports/PATH in ~/.zshrc.platform (optional, sourced below).

# ---------- Shell & History ----------
set -o noclobber
HISTFILE=${HISTFILE:-$HOME/.zsh_history}
HISTSIZE=15000
SAVEHIST=$HISTSIZE
setopt appendhistory inc_append_history sharehistory
unsetopt extended_history
setopt hist_ignore_space hist_ignore_dups hist_ignore_all_dups \
       hist_find_no_dups hist_save_no_dups hist_reduce_blanks \
       hist_save_by_copy

# ---------- Completion ----------
autoload -Uz compinit
compinit -C

# ---------- Plugin Manager (zinit) ----------
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -r "$ZINIT_HOME/zinit.zsh" ]]; then
  mkdir -p "${ZINIT_HOME:h}"
  command git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" >/dev/null 2>&1 || true
fi
[[ -r "$ZINIT_HOME/zinit.zsh" ]] && source "$ZINIT_HOME/zinit.zsh"

# Plugin settings that must be set before load
ZSH_AUTOSUGGEST_STRATEGY=(history)
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=(
  forward-word
  vi-forward-word
  vi-forward-blank-word
  vi-end-of-word
  vi-end-of-blank-word
)

# Core plugins (OS-agnostic)
if typeset -f zinit >/dev/null; then
  zinit light zsh-users/zsh-syntax-highlighting
  zinit light zsh-users/zsh-completions
  zinit light zsh-users/zsh-autosuggestions
  zinit light Aloxaf/fzf-tab
  zinit snippet OMZP::git
  zinit snippet OMZP::sudo
  zinit cdreplay -q
fi

# Completion styles
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu no
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls $realpath'

# ---------- Prompt (oh-my-posh) ----------
if command -v oh-my-posh >/dev/null 2>&1; then
  # Default to repository-managed theme if none provided
  export OMP_CONFIG="${OMP_CONFIG:-$HOME/.config/ohmyposh/zen.toml}"
  if [[ -f "$OMP_CONFIG" ]]; then
    eval "$(oh-my-posh init zsh --config "$OMP_CONFIG")"
  else
    eval "$(oh-my-posh init zsh)"
  fi
fi

# ---------- fzf integration (optional) ----------
if command -v fzf >/dev/null 2>&1; then
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
  else
    [[ -r /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
    [[ -r /usr/share/fzf/completion.zsh    ]] && source /usr/share/fzf/completion.zsh
    [[ -r "$HOME/.fzf.zsh"                ]] && source "$HOME/.fzf.zsh"
    [[ -r "$HOME/.fzf/shell/key-bindings.zsh" ]] && source "$HOME/.fzf/shell/key-bindings.zsh"
    [[ -r "$HOME/.fzf/shell/completion.zsh"    ]] && source "$HOME/.fzf/shell/completion.zsh"
  fi
else
  bindkey '^I' expand-or-complete   # Tab does normal completion if fzf absent
fi

# ---------- zoxide (directory jumper) ----------
if command -v zoxide >/dev/null 2>&1; then
  # Set USE_ZOXIDE_CD=1 in ~/.zshrc.platform to replace `cd` with zoxide.
  if [[ ${USE_ZOXIDE_CD:-0} -eq 1 ]]; then
    eval "$(zoxide init zsh --cmd cd)"
  else
    eval "$(zoxide init zsh)"
  fi
  alias zi='zoxide query -i'
fi

# ---------- Keybindings ----------
bindkey -v
bindkey '^p' history-beginning-search-backward
bindkey '^n' history-beginning-search-forward
bindkey "${terminfo[kcuu1]}" history-beginning-search-backward 2>/dev/null
bindkey "${terminfo[kcud1]}" history-beginning-search-forward 2>/dev/null
bindkey -M vicmd 'k' history-beginning-search-backward
bindkey -M vicmd 'j' history-beginning-search-forward

# Word-wise acceptance of autosuggestions in vi insert mode
bindkey -M viins '^[f' forward-word                   # Alt+f
bindkey -M viins '^[[1;5C' forward-word 2>/dev/null   # Ctrl+Right
bindkey -M viins '^[[1;3C' forward-word 2>/dev/null   # Alt+Right
bindkey -M viins '^[[5C'   forward-word 2>/dev/null
bindkey -M viins '^[OC'    forward-word 2>/dev/null

# ---------- tmux helpers (OS-agnostic) ----------
# Quick aliases
alias tm='tmux'
alias ta='tmux attach -t'
alias tn='tmux new -s'

# Optional auto-attach (set AUTO_ATTACH_TMUX=1 in ~/.zshrc.platform to enable)
typeset -g AUTO_ATTACH_TMUX=${AUTO_ATTACH_TMUX:-0}
maybe_start_tmux() {
  [[ $AUTO_ATTACH_TMUX -eq 1 ]] || return 0
  [[ -o interactive ]] || return 0
  command -v tmux >/dev/null 2>&1 || return 0
  [[ -z "$TMUX" ]] || return 0
  tmux attach -t default 2>/dev/null || tmux new -s default
}
maybe_start_tmux; unset -f maybe_start_tmux

# ---------- Minimal, portable aliases ----------
alias ls='ls -a'
alias c='clear'
alias vim='nvim'
alias q='exit'

# gh copilot auto-execute function
ghcs() {
  local tmpfile=$(mktemp)
  gh copilot suggest -t shell "$@" -s "$tmpfile" 2>/dev/null
  if [[ -f "$tmpfile" && -s "$tmpfile" ]]; then
    local cmd=$(cat "$tmpfile")
    rm "$tmpfile"
    echo "Executing: $cmd"
    eval "$cmd"
  else
    rm -f "$tmpfile"
    echo "No command generated" >&2
    return 1
  fi
}

# ---------- Platform-specific include ----------
# macOS-specific file (if present)
if [[ "$OSTYPE" == darwin* ]] && [[ -r "$HOME/.zshrc.darwin" ]]; then
  source "$HOME/.zshrc.darwin"
fi
# Linux-specific file (managed by dotfiles)
if [[ "$OSTYPE" == linux* ]] && [[ -r "$HOME/.zshrc.linux" ]]; then
  source "$HOME/.zshrc.linux"
fi
# Generic per-host/platform overrides
[[ -r "$HOME/.zshrc.platform" ]] && source "$HOME/.zshrc.platform"
