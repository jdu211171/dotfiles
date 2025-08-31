# Minimal .zshrc
export EDITOR=nvim
export VISUAL=nvim

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Prompt (fallback if oh-my-posh not present)
autoload -U colors && colors
PROMPT='%F{cyan}%n%f@%F{green}%m%f:%F{yellow}%~%f %# '

# Completion
autoload -Uz compinit && compinit

# oh-my-posh prompt (uses config in ~/.config/oh-my-posh/theme.omp.json)
if command -v oh-my-posh >/dev/null 2>&1; then
  eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/zen.toml)"
fi
