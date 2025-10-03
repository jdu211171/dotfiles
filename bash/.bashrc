# ~/.bashrc — minimal, oh-my-posh enabled

# Only run interactive customizations for interactive shells
case $- in
  *i*) ;;
  *) return ;;
esac

# Optional local overrides (ignored by repo)
if [ -f "$HOME/.bashrc.local" ]; then
  . "$HOME/.bashrc.local"
fi

# Shared history with zsh (cross-shell compatible)
# Use ~/.zsh_history as the common history file so zsh autosuggestions
# can learn from bash sessions as well. You can override with SHARED_HISTFILE.
if [[ $- == *i* ]]; then
  : "${SHARED_HISTFILE:=$HOME/.zsh_history}"
  export HISTFILE="$SHARED_HISTFILE"
  export HISTSIZE=${HISTSIZE:-15000}
  export HISTFILESIZE=${HISTFILESIZE:-$HISTSIZE}

  # Append to the history file, don't overwrite it
  shopt -s histappend

  # Keep history sane and useful
  # - ignoreboth = ignorespace:ignoredups
  # - erasedups  = drop older duplicates when saving
  export HISTCONTROL=${HISTCONTROL:-ignoreboth:erasedups}
  # Skip trivial commands from history
  export HISTIGNORE=${HISTIGNORE:-'ls:cd:cd -:pwd:exit:date:* --help'}

  # Immediately append new commands and pull in commands from other sessions.
  # Intentionally keep HISTTIMEFORMAT unset for plain, zsh-readable format.
  if [[ -z ${PROMPT_COMMAND:-} ]]; then
    PROMPT_COMMAND='history -a; history -n'
  else
    PROMPT_COMMAND='history -a; history -n; '${PROMPT_COMMAND}
  fi

  # Optional: fish-like autosuggestions in Bash via ble.sh
  # Install (Arch): pacman -S blesh (AUR: blesh-git) or follow README:
  #   git clone --depth 1 https://github.com/akinomyoga/ble.sh.git
  #   make -C ble.sh install PREFIX=~/.local
  #   echo 'source -- ~/.local/share/blesh/ble.sh' >> ~/.bashrc
  if [[ -r "$HOME/.local/share/blesh/ble.sh" ]]; then
    source "$HOME/.local/share/blesh/ble.sh"
  elif [[ -r "/usr/share/blesh/ble.sh" ]]; then
    source "/usr/share/blesh/ble.sh"
  fi
fi

# Oh My Posh prompt
if command -v oh-my-posh >/dev/null 2>&1; then
  # Respect existing OMP_CONFIG, else use common locations
  if [ -z "${OMP_CONFIG:-}" ]; then
    if [ -f "$HOME/.config/oh-my-posh/zen.toml" ]; then
      export OMP_CONFIG="$HOME/.config/oh-my-posh/zen.toml"
    elif [ -f "$HOME/.config/ohmyposh/zen.toml" ]; then
      export OMP_CONFIG="$HOME/.config/ohmyposh/zen.toml"
    fi
  fi

  if [ -n "${OMP_CONFIG:-}" ] && [ -f "$OMP_CONFIG" ]; then
    eval "$(oh-my-posh init bash --config "$OMP_CONFIG")"
  else
    # Fallback to default theme if no config file is found
    eval "$(oh-my-posh init bash)"
  fi
fi
