unbind r
bind r source-file ~/.tmux.conf

set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",xterm-256color:RGB"

set -g prefix M-s

set -g mouse on

set-window-option -g mode-keys vi

bind-key h select-pane -L
bind-key j select-pane -D
bind-key k select-pane -U
bind-key l select-pane -R
bind-key s choose-session

set-option -g status-position top

# set -g @catppuccin_flavor "mocha"
set -g @catppuccin_window_status_style "rounded"

# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'christoomey/vim-tmux-navigator'
set -g @plugin 'catppuccin/tmux#v2.1.0'

set -g status-left ""
set -g status-right "#{E:@catppuccin_status_application} #{E:@catppuccin_status_session}"

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'

set -g status-style bg=default
