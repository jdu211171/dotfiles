# Repository Guidelines

This repository manages cross‑platform dotfiles using GNU Stow. Treat it as the single source of truth; avoid nested Git repos inside packages. Prefer Git submodules for external upstreams or copy files in and remove any nested `.git`.

## Project Structure & Module Organization
- Packages mirror `$HOME` paths: `nvim/.config/nvim`, `kitty/.config/kitty`, `git/.gitconfig`, `scripts/.local/bin`, `zed/.config/zed`, `ohmyposh/.config/oh-my-posh`.
- Linux‑specific packages: `hypr`, `waybar`, `wofi`, `dunst`, `i3`.
- Per‑host overrides live under `host-laptop/` and should only be stowed on that machine.
- `.stow-local-ignore` keeps repo metadata (e.g., `.git`, `README.md`) from being linked.

## Build, Test, and Development Commands
- `make dry-run`: Preview symlinks (no changes).
- `make stow [PACKAGES="..."]`: Apply symlinks into `$HOME`.
- `make restow`: Re‑apply after edits or moves.
- `make unstow`: Remove symlinks for the selected packages.
- OS-aware helpers:
  - `make stow-os` / `make restow-os`: Use an OS-appropriate default package set (Linux includes Wayland/i3; macOS skips them). Defaults also include `codex` and `gemini`.
  - `make stow-with-host` / `make restow-with-host`: As above and include `host-$(hostname -s)` if present.
- Options: set `TARGET=/path` to change the destination; set `PACKAGES` to a space‑separated subset; set `HOST=name` to force a host overlay.

## Coding Style & Naming Conventions
- Shell scripts (`scripts/.local/bin`): bash, `set -euo pipefail`, small hyphenated names (e.g., `backup-dotfiles`).
- Neovim Lua: format with `stylua` (configured via `.stylua.toml`). Example: `stylua nvim/.config/nvim`.
- JSON/JSONC/Markdown: format with Prettier (`.prettierrc`). Example: `prettier -w zed/.config/zed`.
- Keep config names and folders lowercase; match upstream tool naming.

## Testing Guidelines
- Stow changes safely: `stow -nv -t "$HOME" <package>`; resolve conflicts before `stow`.
- Scripts: run `shellcheck scripts/.local/bin/*` where available; keep scripts idempotent.
- Sanity check affected apps (e.g., launch `nvim`, reload `kitty`, restart `waybar`).

## Commit & Pull Request Guidelines
- Messages: `nvim: add treesitter config`, `kitty: tweak theme`, or `NOISY SYNC: merge local ~/dotfiles` for bulk syncs.
- PRs: describe scope, list affected packages, include before/after snippets or screenshots for UI configs, and link related issues.

## Security & Tips
- Never commit secrets; template as `*.example` and load real values locally.
- macOS: skip Linux‑only packages (`hypr`, `waybar`, `wofi`, `dunst`, `i3`).
- If Stow reports an existing non‑symlink, move it into the correct package and run `make restow`.

### Handling Noisy/Changing Files
- Prefer tracking only stable configs; ignore runtime/state in `.stow-local-ignore` (Codex/Gemini noise patterns included).
- When an app supports local includes, use a base config here and include `~/.<tool>.local` (ignored) for machine-specific or churning settings.
- As a last resort, keep a file tracked but quiet local churn using `git-skip`:
  - `git-skip on path/to/file` to mark skip-worktree; `git-skip off` to resume tracking; `git-skip ls` to list.
