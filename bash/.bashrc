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

  # Enhanced line editor (ble.sh) — load early but attach later
  # This avoids prompt conflicts (e.g. with oh-my-posh) and ensures
  # completion frameworks are initialized before ble attaches.
  if [[ -r "$HOME/.local/share/blesh/ble.sh" ]]; then
    source -- "$HOME/.local/share/blesh/ble.sh" --attach=none
  elif [[ -r "/usr/share/blesh/ble.sh" ]]; then
    source -- "/usr/share/blesh/ble.sh" --attach=none
  fi

  # Bash completion (commands, ssh hosts, git, etc.)
  # Load if installed so TAB completion works comprehensively.
  if [[ -r /usr/share/bash-completion/bash_completion ]]; then
    . /usr/share/bash-completion/bash_completion
  elif [[ -r /etc/bash_completion ]]; then
    . /etc/bash_completion
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

# Attach ble.sh after prompt and other customizations are set up
if [[ -n ${BLE_VERSION-} ]]; then
  ble-attach || { command -v stty >/dev/null 2>&1 && stty sane; }
fi
