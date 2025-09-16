printf '\n%.0s' {1..$LINES}
printf '\n%.0s' {1..$LINES}

# Java configuration
export JAVA_HOME=/home/user/.jdks/amazon-corretto
# export PATH=$PATH:$JAVA_HOME/bin:$PATH
#
# Display system information on terminal launch
# fastfetch

# Standard system PATH directories
# export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export PATH="/home/user/.jdks/amazon-corretto/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

export PATH=$PATH:/home/user/.local/bin
export PATH=$PATH:$HOME/.local/kitty.app/bin
export PATH=$PATH:/usr/local/bin:$PATH
export PATH=$PATH:$HOME/.tmuxifier/bin:$PATH
export PATH=$PATH:$HOME/opt/nvim-linux64/bin

# Detect OS for conditional setup
__OS_NAME__="$(uname -s 2>/dev/null || echo Linux)"

# Homebrew paths (macOS only)
if [ "${__OS_NAME__}" = "Darwin" ]; then
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
fi

# User local bin directory
export PATH="$PATH:$HOME/.local/bin"

# Zed CLI integration: add binary to PATH or alias via flatpak
_setup_zed_cli() {
  # If canonical "zed" exists, nothing to do
  if command -v zed >/dev/null 2>&1; then
    return
  fi

  # Prefer official install locations; add containing dir to PATH if zed is found
  local candidates=(
    "$HOME/.local/share/zed/bin"
    "$HOME/.local/bin"
    "/Applications/Zed.app/Contents/Resources/app/bin"
    "$HOME/Applications/Zed.app/Contents/Resources/app/bin"
    "/usr/local/bin"
    "/opt/homebrew/bin"
  )
  local dir
  for dir in "${candidates[@]}"; do
    if [ -x "$dir/zed" ]; then
      export PATH="$dir:$PATH"
      return
    fi
  done

  # Package managers may name the CLI differently; alias zed to the first match
  local alt
  for alt in zeditor zedit zed-editor; do
    if command -v "$alt" >/dev/null 2>&1; then
      alias zed="$alt"
      return
    fi
  done

  # Flatpak fallback
  if command -v flatpak >/dev/null 2>&1 && flatpak info dev.zed.Zed >/dev/null 2>&1; then
    alias zed="flatpak run dev.zed.Zed"
  fi
}
_setup_zed_cli
unset -f _setup_zed_cli

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
	mkdir -p "$(dirname $ZINIT_HOME)"
	git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# zsh plugins

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo

# Load completions
autoload -U compinit && compinit

zinit cdreplay -q

# Prompt
eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/zen.toml)"

# Prompt (only if oh-my-posh and config exist)
if command -v oh-my-posh >/dev/null 2>&1 && [ -f "$HOME/.config/oh-my-posh/zen.toml" ]; then
  eval "$(oh-my-posh init zsh --config "$HOME/.config/oh-my-posh/zen.toml")"
fi

# Keybindings
bindkey -v
bindkey '^p' history-beginning-search-backward
bindkey '^n' history-beginning-search-forward

# Additional compatibility bindings for different terminals
bindkey "${terminfo[kcuu1]}" history-beginning-search-backward 2>/dev/null
bindkey "${terminfo[kcud1]}" history-beginning-search-forward 2>/dev/null

# Vi mode specific bindings to ensure they work in command mode
bindkey -M vicmd 'k' history-beginning-search-backward
bindkey -M vicmd 'j' history-beginning-search-forward

# History
HISTSIZE=15000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -G $realpath'

# Aliases
alias ls='ls --color'
alias gce='gh copilot explain'
alias gcs='gh copilot suggest'
# alias vim='nvim'
alias c='clear'
alias ls='ls -G'
alias clear="clear && printf '\n%.0s' {1..$LINES} && printf '\n%.0s' {1..$LINES}"
alias c="clear && printf '\n%.0s' {1..$LINES} && printf '\n%.0s' {1..$LINES}"
alias vim='nvim'
alias q='exit'

# Shell integrations
eval "$(zoxide init --cmd cd zsh)"
# Shell integrations (guarded)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init --cmd cd zsh)"
fi

# Android SDK configuration
export ANDROID_HOME="$HOME/.android_sdk"
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
# Robust cd function that falls back to builtin if zoxide isn't available
cd() {
    if type __zoxide_z &>/dev/null; then
        __zoxide_z "$@"
    else
        builtin cd "$@"
    fi
}

export ANDROID_SDK_ROOT="$HOME/.android_sdk"
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH"
export PATH="$ANDROID_SDK_ROOT/platform-tools:$PATH"
export PATH="$ANDROID_SDK_ROOT/emulator:$PATH"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# Enable gh-copilot aliases if extension is installed
if command -v gh >/dev/null 2>&1; then
  if gh extension list 2>/dev/null | grep -q "github/gh-copilot"; then
    __gh_copilot_aliases__="$(gh copilot alias -- zsh 2>/dev/null || true)"
    [ -n "$__gh_copilot_aliases__" ] && eval "$__gh_copilot_aliases__"
  fi
fi

# Function to create files with paths containing special characters
cr() {
  # Save current options and disable globbing
  emulate -L zsh
  setopt local_options no_glob

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(gh copilot alias -- zsh)"
export PATH="$PATH:$HOME/.config/composer/vendor/bin"
  if [[ -z "$1" ]]; then
    echo "Error: No file path provided."
    echo "Usage: create_file <file_path>"
    return 1
  fi

  local filepath="$1"
  local dirpath=$(dirname "${filepath}")

  # Create directory structure if it doesn't exist
  mkdir -p "${dirpath}"
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to create directory structure for ${filepath}"
    return 2
  fi

  # Create the file
  touch "${filepath}"
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to create file ${filepath}"
    return 3
  fi

  echo "✅ Successfully created file: ${filepath}"
  return 0
}

# macOS-only alias for local Claude if present
if [ "${__OS_NAME__}" = "Darwin" ] && [ -x "/Users/muhammadnurislomtukhtamishhoji-zoda/.claude/local/claude" ]; then
  alias claude="/Users/muhammadnurislomtukhtamishhoji-zoda/.claude/local/claude"
fi

# Java Version Management
jdks() {
  local java_home_base="$HOME/.jdks"

  # Check if the base directory exists
  if [[ ! -d "$java_home_base" ]]; then
    echo "Error: Java directory not found at $java_home_base"
    return 1
  fi

  # Get list of Java versions
  local versions=()
  local version_names=()

  for dir in "$java_home_base"/*; do
    if [[ -d "$dir" && ! "$dir" =~ \.intellij$ ]]; then
      local basename=$(basename "$dir")
      # Extract version number using regex
      if [[ "$basename" =~ ([0-9]+(\.[0-9]+)*) ]]; then
        local version="${match[1]}"
        versions+=("$dir")
        version_names+=("$basename (Java $version)")
      else
        versions+=("$dir")
        version_names+=("$basename")
      fi
    fi
  done

  # Check if any versions found
  if [[ ${#versions[@]} -eq 0 ]]; then
    echo "No Java versions found in $java_home_base"
    return 1
  fi

  # If no argument provided, show menu
  if [[ -z "$1" ]]; then
    echo "Available Java versions:"
    for i in {1..${#versions[@]}}; do
      echo "  $i) ${version_names[$i]}"
    done

    echo -n "Select Java version (1-${#versions[@]}): "
    read selection

    # Validate selection
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [[ $selection -lt 1 ]] || [[ $selection -gt ${#versions[@]} ]]; then
      echo "Invalid selection"
      return 1
    fi

    local selected_java="${versions[$selection]}"
  else
    # Direct version selection via argument (e.g., jdk 21)
    local selected_java=""
    for dir in "${versions[@]}"; do
      if [[ "$(basename "$dir")" =~ "$1" ]]; then
        selected_java="$dir"
        break
      fi
    done

    if [[ -z "$selected_java" ]]; then
      echo "Java version '$1' not found"
      echo "Available versions:"
      for name in "${version_names[@]}"; do
        echo "  - $name"
      done
      return 1
    fi
  fi

  # Set JAVA_HOME
  export JAVA_HOME="$selected_java/Contents/Home"
  export PATH="$JAVA_HOME/bin:$PATH"

  # Remove any other Java paths from PATH to avoid conflicts
  export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v "Java/JavaVirtualMachines" | grep -v "^$" | tr '\n' ':' | sed 's/:$//')
  export PATH="$JAVA_HOME/bin:$PATH"

  # Save the selection to a file for persistence
  echo "export JAVA_HOME=\"$selected_java/Contents/Home\"" > "$HOME/.java_version"

  echo "✅ Java version set to: $(basename "$selected_java")"
  echo "JAVA_HOME: $JAVA_HOME"
  java -version
}

# Load saved Java version on shell startup
if [[ -f "$HOME/.java_version" ]]; then
  source "$HOME/.java_version"
  if [[ -n "$JAVA_HOME" && -d "$JAVA_HOME" ]]; then
    export PATH="$JAVA_HOME/bin:$PATH"
  fi
fi
if [ "${__OS_NAME__}" = "Darwin" ]; then
  export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
  export PATH=$PATH:/usr/local/mysql-8.4.5-macos15-arm64/bin
fi
export PATH=$HOME/.nodebrew/current/bin:$PATH

# Android SDK paths (macOS default; adjust on Linux if needed)
if [ "${__OS_NAME__}" = "Darwin" ]; then
  export ANDROID_HOME="$HOME/Library/Android/sdk"
  export PATH="$PATH:$ANDROID_HOME/platform-tools"
  export PATH="$PATH:$ANDROID_HOME/tools"
  export PATH="$PATH:$ANDROID_HOME/tools/bin"
  export PATH="$PATH:$ANDROID_HOME/emulator"
fi

# Google Cloud SDK (macOS specific path)
if [ "${__OS_NAME__}" = "Darwin" ]; then
  # The next line updates PATH for the Google Cloud SDK.
  if [ -f '/Users/muhammadnurislomtukhtamishhoji-zoda/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/muhammadnurislomtukhtamishhoji-zoda/google-cloud-sdk/path.zsh.inc'; fi
  # The next line enables shell command completion for gcloud.
  if [ -f '/Users/muhammadnurislomtukhtamishhoji-zoda/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/muhammadnurislomtukhtamishhoji-zoda/google-cloud-sdk/completion.zsh.inc'; fi
fi

# Node version switching aliases
alias node16='nodebrew use v16.20.2'
alias node20='nodebrew use v20.16.0'

# Toppan Machi Info project helper
toppan() {
  nodebrew use v16.20.2
  cd ~/Development/toppan-machi-info
  echo "✅ Switched to Node 16.20.2 for Toppan Machi Info"
  echo "📍 Current directory: $(pwd)"
  echo "🔧 Node version: $(node -v)"
}
export MAX_THINKING_TOKENS=31999

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
# SSH agent via systemd user service
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# mac helper: optional IP overrides HostName
mac() {
  if [ -n "$1" ]; then
    ssh -o HostName="$1" mac
  else
    ssh mac
  fi
}
# Wrapper around ssh to allow: ssh mac <ip>
ssh() {
  if [ "$#" -ge 2 ] && [ "$1" = "mac" ]; then
    local ip="$2"; shift 2
    command ssh -o HostName="$ip" mac "$@"
  else
    command ssh "$@"
  fi
}

# Hypr theme shortcut: tt
# Usage:
#   tt                # interactive picker (fzf if available, else numbered)
#   tt <theme-name>   # apply directly
tt() {
  if [ $# -eq 0 ]; then
    # Build theme list from JSON names
    local themes
    themes=$(jq -r '.name' "$HOME/.local/share/hypr/themes"/*.json 2>/dev/null)
    if [ -z "$themes" ]; then
      echo "No themes found in $HOME/.local/share/hypr/themes" >&2
      return 1
    fi

eval "$(tmuxifier init -)"
    if command -v fzf >/dev/null 2>&1; then
      local choice
      choice=$(print -r -- $themes | fzf --prompt='Theme > ' --height=40% --reverse)
      [ -n "$choice" ] || return 0
      ~/.config/hypr/themectl.sh apply "$choice"
      return $?
    else
      # Simple numbered menu
      local -a arr
      arr=(${(f)themes})
      echo "Select theme:"
      local i=1
      for t in "${arr[@]}"; do
        echo "  $i) $t"
        i=$((i+1))
      done
      printf "Enter number: "
      local sel
      read sel
      if [[ "$sel" =~ '^[0-9]+$' ]] && [ "$sel" -ge 1 ] && [ "$sel" -le ${#arr[@]} ]; then
        ~/.config/hypr/themectl.sh apply "${arr[$sel]}"
      else
        echo "Invalid selection" >&2
        return 1
      fi
      return $?
    fi
  fi
  ~/.config/hypr/themectl.sh apply "$@"
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# zsh completion for tt: complete with available theme names
_tt() {
  emulate -L zsh
  setopt local_options no_aliases
  local -a themes
  themes=( ${(f)$(jq -r '.name' "$HOME/.local/share/hypr/themes"/*.json 2>/dev/null)} )
  compadd -- ${themes[@]}
}
compdef _tt tt
