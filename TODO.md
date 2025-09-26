# Dotfiles TODO

Prioritized tasks to make the repo clean, cross‑platform, and conflict‑free.

## High Priority — Cleanup & Structure

- [ ] Neovim: consolidate to `nvim/.config/nvim/*` only
  - [ ] Remove top‑level duplicates: `nvim/init.lua`, `nvim/lazy-lock.json`, `nvim/LICENSE`, `nvim/README.md`, `nvim/.prettierrc`, `nvim/.stylua.toml`
  - [ ] Remove stray metadata: `nvim/.config/nvim/.DS_Store`, `nvim/.config/nvim/lua/.DS_Store`, `nvim/.config/nvim/lua/configs/.DS_Store`, `nvim/.config/nvim/lua/configs/conform/.DS_Store`
  - [ ] Add package ignore: create `nvim/.stow-local-ignore` to exclude `^LICENSE$`, `^README\.md$`, `^\.prettierrc$`, `^\.stylua\.toml$` from being stowed to `$HOME`

- [ ] Kitty: unify under `kitty/.config/kitty/*`
  - [ ] Move theme: `kitty/current-theme.conf` → `kitty/.config/kitty/current-theme.conf`
  - [ ] Replace minimal `kitty/.config/kitty/kitty.conf` with the full `kitty/kitty.conf` (then remove the latter)
  - [ ] Remove backup: `kitty/kitty.conf.bak`

- [ ] Zed: keep only `zed/.config/zed/{settings.json,keymap.json}`
  - [ ] Remove top‑level duplicates: `zed/settings.json`, `zed/keymap.json`

- [ ] Git: single source of truth under `git/`
  - [ ] Base stays in `git/.gitconfig` (name, email, color, editor, defaultBranch)
  - [ ] Create `host-linux/git/.gitconfig.local` and move Linux‑specific extras from root `.gitconfig`:
        `core.autocrlf=input`, `core.eol=lf`, `pull.rebase=true`, GitHub credential helpers (gh path), `filter.lfs.*`, `rebase.autoStash=true`
  - [ ] (Optional) Create `host-macos/git/.gitconfig.local` with correct macOS `gh` path (e.g., `/opt/homebrew/bin/gh`)
  - [ ] Add safe include in base: `~/.gitconfig.local` (ok if missing)
  - [ ] Remove root `.gitconfig`

- [ ] Tmux: choose one configuration
  - [ ] If keeping minimal `tmux/.tmux.conf`, remove legacy root `~/.tmux`
  - [ ] Otherwise, port content from `.tmux` into `tmux/.tmux.conf` and delete the existing minimal file

- [ ] i3: fix path
  - [ ] Move `i3/config` → `i3/.config/i3/config`

- [ ] Oh My Posh: fix path
  - [ ] Create `ohmyposh/.config/oh-my-posh/`
  - [ ] Move `ohmyposh/zen.toml` → `ohmyposh/.config/oh-my-posh/zen.toml`
  - [ ] Remove backup: `ohmyposh/zen.toml.bak`

- [ ] Zsh: add package
  - [ ] Create `zsh/` and move root `.zshrc` → `zsh/.zshrc`

- [ ] Remove tracked backups/metadata
  - [ ] Delete any committed `.DS_Store`
  - [ ] Remove `*.bak` files already tracked (kitty/ohmyposh)

## Cross‑Platform & Overrides

- [ ] Hyprland includes
  - [ ] Replace absolute includes (`/home/user/...`) with `~/.config/hypr/...` or `$XDG_CONFIG_HOME`
  - [ ] Ensure `hypr/.config/hypr/hyprland.conf` also `source = ~/.config/hypr/host.conf` (ignore if missing)

- [ ] Git includes
  - [ ] Add to `git/.gitconfig`: `
[include]
    path = ~/.gitconfig.local
    `

- [ ] Kitty conditional includes
  - [ ] Keep `include current-theme.conf`; optionally add `include os.conf` if present (for OS‑specific tweaks)

- [ ] Neovim OS gating
  - [ ] Use `vim.loop.os_uname().sysname` to branch small platform tweaks (e.g., clipboard, shell) without separate files

- [ ] Host packages
  - [ ] Keep overrides under `host-<name>/...`, stow only on matching host
  - [ ] Keep overrides minimal and include from base configs (no full copies)

## Makefile & Scripts

- [ ] Makefile: OS‑aware defaults
  - [ ] Split sets: `PACKAGES_COMMON`, `PACKAGES_LINUX`, `PACKAGES_MACOS`
  - [ ] Use `uname` to default `PACKAGES` appropriately while still allowing overrides

- [ ] Bootstrap helper
  - [ ] Move `scripts/setup.sh` → `scripts/.local/bin/stow-apply` (bash, `set -euo pipefail`)
  - [ ] Add `scripts/.local/bin/stow-dry-run` convenience wrapper
  - [ ] Update README examples to use the helper

## Documentation

- [ ] README: align names and paths
  - [ ] Use package name `ohmyposh` (tool dir is `.config/oh-my-posh`)
  - [ ] Update package list examples for macOS vs Linux
  - [ ] Note per‑host workflow (`host-laptop/` only on that machine)

## Quality, Safety & Checks

- [ ] Stow safety workflow
  - [ ] Always run `make dry-run` and resolve conflicts before `stow/restow`

- [ ] Formatting & linting
  - [ ] Neovim Lua: `stylua nvim/.config/nvim`
  - [ ] JSON/JSONC/Markdown: `prettier -w zed/.config/zed waybar/.config/waybar`
  - [ ] Shell scripts: `shellcheck scripts/.local/bin/*`

- [ ] (Optional) Pre-commit
  - [ ] Add hooks to run `stylua --check`, `prettier -c`, and `shellcheck`

## After Migration (Verification)

- [ ] On Linux/macOS: `git pull && make dry-run && make restow`
- [ ] Sanity check: launch `nvim`, reload `kitty`, verify Hyprland/Waybar (Linux)
- [ ] Confirm Git includes resolve and gh credential helper path is correct per OS
