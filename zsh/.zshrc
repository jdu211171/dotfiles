# ~/.zshrc — streamlined for clarity and speed (2025-09-14)
# - Minimal PATH edits via zsh's `path` array (de-duplicated)
# - Logical sections; guarded integrations; removed redundancies

# 1) Basic shell behavior and history
set -o noclobber

# Use a shared, bash-compatible history file so both shells learn together
: ${SHARED_HISTFILE:=$HOME/.zsh_history}
HISTFILE=$SHARED_HISTFILE
HISTSIZE=15000
SAVEHIST=$HISTSIZE

# History behavior
# - APPEND_HISTORY: append instead of overwrite
# - INC_APPEND_HISTORY: write each line as it’s executed
# - SHARE_HISTORY: merge new lines from other shells on the fly
# - (no)EXTENDED_HISTORY: keep plain format compatible with bash
setopt appendhistory inc_append_history sharehistory
unsetopt extended_history

# De-dup, skip noisy lines, reduce blanks
setopt hist_ignore_space hist_ignore_dups hist_ignore_all_dups hist_find_no_dups hist_save_no_dups hist_reduce_blanks

# Improve safety of concurrent writes to the history file
setopt hist_save_by_copy

# 2) Linux-only config (macOS-specific logic removed)

# 3) Path management (use arrays; ensure uniqueness)
typeset -U path PATH
# Prune inherited PATH entries that don't exist (keeps your PATH tidy)
{ 
  local -a _clean; local d
  for d in $path; do [[ -d $d ]] && _clean+=("$d"); done
  path=($_clean)
  unset _clean d
}
_prepend_path() { [[ -d $1 ]] && path=($1 $path); }
_append_path()  { [[ -d $1 ]] && path+=$1; }

# 4) Core environment variables (grouped)

# Android SDK (optional)
export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/.android_sdk}"
export ANDROID_HOME="$ANDROID_SDK_ROOT"

# Bun
export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"
_prepend_path "$BUN_INSTALL/bin"

# SSH agent (systemd user service)
export SSH_AUTH_SOCK="${SSH_AUTH_SOCK:-$XDG_RUNTIME_DIR/ssh-agent.socket}"

# Optional app-specific vars
export MAX_THINKING_TOKENS="${MAX_THINKING_TOKENS:-31999}"

# 5) Baseline PATH additions (lightweight; only if dirs exist)
_append_path "$HOME/.local/bin"
_append_path "$HOME/.tmuxifier/bin"

# Android tools in PATH (skipped unless present)
# Paths were pruned earlier if missing.

# Google Cloud SDK (load if installed)
[[ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]] && source "$HOME/google-cloud-sdk/path.zsh.inc"
[[ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]] && source "$HOME/google-cloud-sdk/completion.zsh.inc"

# Done with helpers
unset -f _prepend_path _append_path

# 8) Zed CLI: locate or alias
_setup_zed_cli() {
  if command -v zed >/dev/null 2>&1; then return; fi
  local candidates=(
    "$HOME/.local/share/zed/bin"
    "$HOME/.local/bin"
    "/usr/local/bin"
  )
  local dir
  for dir in "${candidates[@]}"; do
    if [[ -x "$dir/zed" ]]; then
      path=($dir $path)
      return
    fi
  done
  local alt
  for alt in zeditor zedit zed-editor; do
    if command -v "$alt" >/dev/null 2>&1; then
      alias zed="$alt"; return
    fi
  done
  if command -v flatpak >/dev/null 2>&1 && flatpak info dev.zed.Zed >/dev/null 2>&1; then
    alias zed="flatpak run dev.zed.Zed"
  fi
}
_setup_zed_cli; unset -f _setup_zed_cli

# 9) Plugin manager (zinit) and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "${ZINIT_HOME:h}" && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"

# Plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit snippet OMZP::git
zinit snippet OMZP::sudo

# 10) Completion
autoload -Uz compinit
compinit -C
zinit cdreplay -q
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color=auto $realpath'

# 11) Prompt (oh-my-posh) — use exported config if present
# Prefer your previous layout from ~/Templates/.zshrc: ~/.config/ohmyposh/zen.toml
# Expose it via OMP_CONFIG so you can swap designs easily.
if command -v oh-my-posh >/dev/null 2>&1; then
  # If not already set, default to your known config path
  export OMP_CONFIG="${OMP_CONFIG:-$HOME/.config/ohmyposh/zen.toml}"
  if [[ -n "$OMP_CONFIG" && -f "$OMP_CONFIG" ]]; then
    eval "$(oh-my-posh init zsh --config "$OMP_CONFIG")"
  elif [[ -f "$HOME/.config/oh-my-posh/zen.toml" ]]; then
    export OMP_CONFIG="$HOME/.config/oh-my-posh/zen.toml"
    eval "$(oh-my-posh init zsh --config "$OMP_CONFIG")"
  else
    # Fallback to oh-my-posh defaults if no config file is found
    eval "$(oh-my-posh init zsh)"
  fi
fi

# 12) Keybindings
bindkey -v
bindkey '^p' history-beginning-search-backward
bindkey '^n' history-beginning-search-forward
bindkey "${terminfo[kcuu1]}" history-beginning-search-backward 2>/dev/null
bindkey "${terminfo[kcud1]}" history-beginning-search-forward 2>/dev/null
bindkey -M vicmd 'k' history-beginning-search-backward
bindkey -M vicmd 'j' history-beginning-search-forward

# If fzf isn't installed, make Tab do normal completion
if ! command -v fzf >/dev/null 2>&1; then
  bindkey '^I' expand-or-complete
fi

# fzf integration (>= 0.48 supports one-liner). Keep after vi-mode bindings.
if command -v fzf >/dev/null 2>&1; then
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
  else
    if [[ -r /usr/share/fzf/key-bindings.zsh ]]; then
      source /usr/share/fzf/key-bindings.zsh
    fi
    if [[ -r /usr/share/fzf/completion.zsh ]]; then
      source /usr/share/fzf/completion.zsh
    fi
    if [[ -r "$HOME/.fzf.zsh" ]]; then
      source "$HOME/.fzf.zsh"
    elif [[ -r "$HOME/.fzf/shell/key-bindings.zsh" ]]; then
      source "$HOME/.fzf/shell/key-bindings.zsh"
      [[ -r "$HOME/.fzf/shell/completion.zsh" ]] && source "$HOME/.fzf/shell/completion.zsh"
    fi
  fi
fi

# 13) Aliases (deduplicated)
alias ls='ls --color=auto -a'
# alias c='clear && printf "\n%.0s" {1..$LINES} && printf "\n%.0s" {1..$LINES}'
alias c='clear'
alias vim='nvim'
alias q='exit'
alias ghce='gh copilot explain'

# 14) Tooling integrations (guarded)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init --cmd cd zsh)"
fi
# fzf is initialized above; keep legacy line disabled to avoid double-loading.
# [[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"

# Suggest a command using Copilot and execute in current shell
# Uses a temp file and dynamically respects $SHELL.
unalias ghcs 2>/dev/null
ghcs() {
  local _copilot_tmp
  _copilot_tmp=$(mktemp -p "${TMPDIR:-/tmp}" ghcs.XXXXXXXX) || return
  gh copilot suggest --shell-out="${_copilot_tmp}" "$@"
  if [[ -s "${_copilot_tmp}" ]]; then
    local _sh=${SHELL:-/bin/sh}
    case "$_sh" in
      *zsh|*bash|*sh) . "${_copilot_tmp}" ;;
      *fish) fish "${_copilot_tmp}" ;;
      *) "$_sh" -c ". \"${_copilot_tmp}\"" ;;
    esac
  fi
  rm -f -- "${_copilot_tmp}"
}

if command -v tmuxifier >/dev/null 2>&1; then
  eval "$(tmuxifier init -)"
fi

# 15) Functions
# Safer cd: use zoxide if available, else builtin
cd() {
  if type __zoxide_z &>/dev/null; then
    __zoxide_z "$@"
  else
    builtin cd "$@"
  fi
}

# Create file with intermediate directories
cr() {
  emulate -L zsh
  setopt local_options no_glob
  if [[ -z "$1" ]]; then
    echo "Error: No file path provided."; echo "Usage: cr <file_path>"; return 1
  fi
  local filepath="$1" dirpath
  dirpath=$(dirname -- "$filepath") || return 2
  mkdir -p -- "$dirpath" || { echo "Error: Failed to create directory $dirpath"; return 2; }
  : > "$filepath" || { echo "Error: Failed to create $filepath"; return 3; }
  echo "✅ Created: $filepath"
}

# (Removed) Java/JDK switcher and SSH helper functions for minimal config

# Hyprland theme switcher (tt)
tt() {
  if [[ $# -eq 0 ]]; then
    local themes choice
    themes=$(jq -r '.name' "$HOME/.local/share/hypr/themes"/*.json 2>/dev/null)
    [[ -n "$themes" ]] || { echo "No themes found in $HOME/.local/share/hypr/themes" >&2; return 1; }
    if command -v fzf >/dev/null 2>&1; then
      choice=$(print -r -- $themes | fzf --prompt='Theme > ' --height=40% --reverse)
      [[ -n "$choice" ]] || return 0
      "$HOME/.config/hypr/themectl.sh" apply "$choice"
    else
      local -a arr; arr=(${(f)themes})
      echo "Select theme:"; local i=1; for t in "${arr[@]}"; do echo "  $i) $t"; ((i++)); done
      printf "Enter number: "; local sel; read -r sel
      if [[ ! "$sel" =~ ^[0-9]+$ ]] || (( sel < 1 || sel > ${#arr[@]} )); then
        echo "Invalid selection" >&2; return 1
      fi
      "$HOME/.config/hypr/themectl.sh" apply "${arr[$sel]}"
    fi
  else
    "$HOME/.config/hypr/themectl.sh" apply "$@"
  fi
}
_tt() { emulate -L zsh; setopt local_options no_aliases; local -a themes; themes=( ${(f)$(jq -r '.name' "$HOME/.local/share/hypr/themes"/*.json 2>/dev/null)} ); compadd -- ${themes[@]} }
compdef _tt tt

# Project helpers
# (Removed) Nodebrew aliases and project helper; using nvm only

# 16) Node version manager (nvm) — optional
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && . "$NVM_DIR/bash_completion"

# 17) MCP credentials (GitHub, Supabase)
# Load private env files if present; keeps secrets out of .zshrc
if [[ -f "$HOME/.mcp-auth/github.env" ]]; then
  set -a
  source "$HOME/.mcp-auth/github.env"
  set +a
fi
if [[ -f "$HOME/.mcp-auth/supabase.env" ]]; then
  set -a
  source "$HOME/.mcp-auth/supabase.env"
  set +a
fi
# Default to dynamic toolsets unless overridden in the env file
export GITHUB_DYNAMIC_TOOLSETS="${GITHUB_DYNAMIC_TOOLSETS:-1}"

# Warp-style bottom statusline rendered on each prompt
# if [[ -t 1 && -z ${_WARP_STATUSLINE_INIT:-} ]]; then
#  typeset -g _WARP_STATUSLINE_INIT=1
#  autoload -Uz add-zsh-hook
#
#  typeset -g _warp_statusline_last_status=0
#
#  _warp_statusline_content() {
#    local _status=$1
#    local dir=${PWD/#$HOME/~}
#    local indicator
#    if (( _status == 0 )); then
#      indicator="OK"
#    else
#      indicator="ERR $_status"
#    fi
#
#    local git_info=""
#    if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
#      local branch dirty_flag="" git_state
#      branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
#      git_state=$(git status --porcelain 2>/dev/null)
#      if [[ -n "$branch" ]]; then
#        [[ -n "$git_state" ]] && dirty_flag="*"
#        git_info=" · git:${branch}${dirty_flag}"
#      fi
#    fi
#
#    local venv=""
#    if [[ -n "$VIRTUAL_ENV" ]]; then
#      venv=" · venv:${VIRTUAL_ENV:t}"
#    fi
#
#    local clock
#    clock="$(date +'%H:%M:%S')"
#
#    printf ' %s | %s%s%s | %s ' "$indicator" "$dir" "$git_info" "$venv" "$clock"
#  }
#
#  _warp_statusline_draw() {
#    local _status_arg=${1:-$_warp_statusline_last_status}
#    [[ -t 1 ]] || return
#    local cols=${COLUMNS:-$(tput cols 2>/dev/null)}
#    local rows=${LINES:-$(tput lines 2>/dev/null)}
#    (( rows > 0 && cols > 0 )) || return
#
#    local content
#    content=$(_warp_statusline_content "$_status_arg")
#
#    tput sc 2>/dev/null
#    tput civis 2>/dev/null
#    tput cup $((rows - 1)) 0 2>/dev/null
#    tput el 2>/dev/null
#    printf '%-*s' "$cols" "$content"
#    tput cnorm 2>/dev/null
#    tput rc 2>/dev/null
#  }
#
#  _warp_statusline_position_prompt() {
#    [[ -t 1 ]] || return
#    local rows=${LINES:-$(tput lines 2>/dev/null)}
#    (( rows > 1 )) || return
#    tput cup $((rows - 2)) 0 2>/dev/null
#    tput el 2>/dev/null
#  }
#
#  _warp_statusline_precmd() {
#    _warp_statusline_last_status=$?
#    _warp_statusline_draw "$_warp_statusline_last_status"
#    _warp_statusline_position_prompt
#  }
#
#  _warp_statusline_preexec() {
#    [[ -t 1 ]] || return
#    local rows=${LINES:-$(tput lines 2>/dev/null)}
#    (( rows > 0 )) || return
#    tput sc 2>/dev/null
#    tput cup $((rows - 1)) 0 2>/dev/null
#    tput el 2>/dev/null
#    tput cnorm 2>/dev/null
#    tput rc 2>/dev/null
#  }
#
#  add-zsh-hook precmd _warp_statusline_precmd
#  add-zsh-hook preexec _warp_statusline_preexec
#
#  TRAPWINCH() { _warp_statusline_draw "$_warp_statusline_last_status"; return 0 }
# fi

# --- tmux auto-attach on interactive shells ---
# Attaches to the most recently used tmux session if one exists; otherwise
# starts a new server (tmux-continuum + resurrect will auto-restore if enabled).
# Set TMUX_AUTO_DISABLE=1 to skip for a shell.
if command -v tmux >/dev/null 2>&1; then
  if [[ -z "$TMUX" && $- == *i* && -z "${TMUX_AUTO_DISABLE:-}" ]]; then
    # If a server is running, pick the most-recently attached session
    if tmux ls >/dev/null 2>&1; then
      local _tmux_recent
      _tmux_recent=$(tmux ls -F '#{session_last_attached} #{session_name}' 2>/dev/null | sort -rn | awk 'NR==1{print $2}')
      exec tmux attach -d -t "${_tmux_recent:-main}"
    else
      exec tmux
    fi
  fi
fi
