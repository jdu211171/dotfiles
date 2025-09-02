##############################
# Shell performance & PATH   #
##############################
# Keep PATH entries unique (prevents bloat/duplication)
typeset -U path PATH

# Baseline PATH (prepend JAVA tools if present)
export PATH="$HOME/.local/bin:$HOME/.config/composer/vendor/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Java configuration (adjust JAVA_HOME if needed)
# export JAVA_HOME=/home/user/.jdks/amazon-corretto
# export PATH="$JAVA_HOME/bin:$PATH"

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

# Load plugins (async where safe)
zinit ice wait lucid depth=1
zinit light zsh-users/zsh-completions

zinit ice wait lucid depth=1
zinit light zsh-users/zsh-autosuggestions

zinit ice wait lucid depth=1
zinit light Aloxaf/fzf-tab

# syntax highlighting should load last
zinit light zsh-users/zsh-syntax-highlighting

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo

# Completion cache and init
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zcompcache
autoload -Uz compinit && compinit -C

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
export PATH="$ANDROID_HOME/emulator:$PATH"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
export PATH="$ANDROID_HOME/platform-tools:$PATH"

export ANDROID_SDK_ROOT="$HOME/.android_sdk"
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH"
export PATH="$ANDROID_SDK_ROOT/platform-tools:$PATH"
export PATH="$ANDROID_SDK_ROOT/emulator:$PATH"


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
command -v gh >/dev/null 2>&1 && eval "$(gh copilot alias -- zsh)"

# eval "$(tmuxifier init -)"   # commented out per request

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Load environment variables from ~/.env if it exists (safe)
set -a
[ -f ~/.env ] && . ~/.env
set +a

# Added for Bun
export BUN_INSTALL="/Users/muhammadnurislomtukhtamishhoji-zoda/.bun"
export PATH="/Users/muhammadnurislomtukhtamishhoji-zoda/.bun/bin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/var/folders/h7/kwq_f9md4zv8q8f1mzn_tgh00000gn/T/.tmpxwKozK:/Users/muhammadnurislomtukhtamishhoji-zoda/.bun/install/global/node_modules/@vscode/ripgrep/bin:/Users/muhammadnurislomtukhtamishhoji-zoda/.nvm/versions/node/v24.2.0/bin:/Users/muhammadnurislomtukhtamishhoji-zoda/.android_sdk/emulator:/Users/muhammadnurislomtukhtamishhoji-zoda/.android_sdk/platform-tools:/Users/muhammadnurislomtukhtamishhoji-zoda/.android_sdk/cmdline-tools/latest/bin:/home/user/.jdks/amazon-corretto/bin:/usr/local/sbin:/Library/PostgreSQL/17/bin:/Users/muhammadnurislomtukhtamishhoji-zoda/.bun/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/Users/muhammadnurislomtukhtamishhoji-zoda/.local/share/zinit/polaris/bin:/Users/muhammadnurislomtukhtamishhoji-zoda/Library/Application Support/JetBrains/Toolbox/scripts:/home/user/.local/bin:/Users/muhammadnurislomtukhtamishhoji-zoda/.local/kitty.app/bin:/Users/muhammadnurislomtukhtamishhoji-zoda/.tmuxifier/bin:/Users/muhammadnurislomtukhtamishhoji-zoda/opt/nvim-linux64/bin:/Users/muhammadnurislomtukhtamishhoji-zoda/.config/composer/vendor/bin"
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/muhammadnurislomtukhtamishhoji-zoda/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
# source "/Users/muhammadnurislomtukhtamishhoji-zoda/google-cloud-sdk/path.zsh.inc"
# source "/Users/muhammadnurislomtukhtamishhoji-zoda/google-cloud-sdk/completion.zsh.inc#"
