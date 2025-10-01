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

