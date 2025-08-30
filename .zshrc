# Java configuration
export JAVA_HOME=/home/user/.jdks/amazon-corretto
# export PATH=$PATH:$JAVA_HOME/bin:$PATH


# Standard system PATH directories 
# export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export PATH="/home/user/.jdks/amazon-corretto/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

export PATH=$PATH:/home/user/.local/bin
export PATH=$PATH:$HOME/.local/kitty.app/bin
export PATH=$PATH:/usr/local/bin:$PATH
export PATH=$PATH:$HOME/.tmuxifier/bin:$PATH
export PATH=$PATH:$HOME/opt/nvim-linux64/bin

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

# Keybindings
bindkey -v
bindkey '^p' history-beginning-search-backward
bindkey '^n' history-beginning-search-forward


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

# Aliases
alias ls='ls --color'
alias gce='gh copilot explain'
alias gcs='gh copilot suggest'
# alias vim='nvim'
alias c='clear'
alias q='exit'

# Shell integrations
eval "$(zoxide init --cmd cd zsh)"

# Android SDK configuration
export ANDROID_HOME="$HOME/.android_sdk"
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
export PATH="$PATH:$ANDROID_HOME/platform-tools"

export ANDROID_SDK_ROOT="$HOME/.android_sdk"
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH"
export PATH="$ANDROID_SDK_ROOT/platform-tools:$PATH"
export PATH="$ANDROID_SDK_ROOT/emulator:$PATH"


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(gh copilot alias -- zsh)"
export PATH="$PATH:$HOME/.config/composer/vendor/bin"

eval "$(tmuxifier init -)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
