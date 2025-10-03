# Shared Shell History (bash + zsh)

This repo configures Bash and Zsh to share a single history file so that:

- Zsh autosuggestions learn from commands run in Bash
- Multiple shells merge history live without clobbering

## How it works

- Common file: `~/.zsh_history` (override with `SHARED_HISTFILE`)
- Zsh: `appendhistory`, `inc_append_history`, `sharehistory` are enabled; `extended_history` is disabled for bash-compatible format.
- Bash: `HISTFILE=$SHARED_HISTFILE`, `histappend` enabled, and `PROMPT_COMMAND` appends and refreshes history each prompt.

Notes:
- We intentionally keep Bash `HISTTIMEFORMAT` unset and Zsh `extended_history` disabled to keep the file format simple and compatible.
- Duplicate suppression is enabled on both shells.

## Configure

You can point both shells at a different file by exporting:

```
export SHARED_HISTFILE="$HOME/.shared_history"
```

Add that to `~/.bashrc.local` and/or `~/.zshrc.local` if you want a per-machine override.

## Stow

- Linux/macOS: `make stow PACKAGES="bash zsh"`
- With host overlay: `make stow-with-host PACKAGES="bash zsh"`

Verify:

1. Open a Bash shell, run a unique command (e.g. `echo bash-only-123`).
2. Open a Zsh shell; start typing `echo bash-` and confirm autosuggestion appears.

## References

- Zsh User Guide – History options: https://zsh.sourceforge.io/Guide/zshguide02.html#l1268
- Bash manual – History control: https://www.gnu.org/software/bash/manual/bash.html#Bash-History-Builtins

## Optional: Bash autosuggestions

If you want fish/zsh-style history suggestions while typing in Bash, enable `ble.sh`:

- Install (quick):
  - Arch: `pacman -S blesh` (AUR: `blesh-git`)
  - Git: `git clone --depth 1 https://github.com/akinomyoga/ble.sh.git && make -C ble.sh install PREFIX=~/.local && echo 'source -- ~/.local/share/blesh/ble.sh' >> ~/.bashrc`
- After sourcing, this repo sets:
  - `bleopt history_share=1` to sync with `HISTFILE` on each command
  - `bleopt complete_auto_*` to enable autosuggestions from your shared history
  - `ble-face auto_complete='fg=242'` to render suggestions in faint grey

Docs:
- ble.sh README: https://github.com/akinomyoga/ble.sh
- Auto-complete from history: https://github.com/akinomyoga/ble.sh/wiki/Manual-%C2%A77-Completion#user-content-bleopt-complete_auto_history

## Optional: Zsh autosuggestions style

Zsh uses `zsh-autosuggestions`. If you want faint grey like Bash, add in a local override (not set by this repo):

```
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'
```
