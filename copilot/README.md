GitHub Copilot CLI

This package provides a safe, template-based setup for GitHub Copilot CLI configuration, following the repository’s security guidelines (no secrets committed).

What you get
- `~/.copilot/config.json.example`: Accessible defaults (no tokens).
- `copilot-init-config` helper script: Creates `~/.copilot/config.json` locally if missing.

Install
- Stow this package: `make stow PACKAGES="copilot scripts"`
- Initialize config (non-destructive): `copilot-init-config`
- Launch Copilot CLI: `copilot`, then run `/login` in the prompt if asked.

Accessible defaults in the example
- `screen_reader: true` to optimize TUI for screen readers.
- `render_markdown: true` (set to `false` if your reader prefers plain text).
- `theme: "auto"` (use `/theme set dark|light` to override).
- `banner: "once"` (you can change to `never`).

Notes
- Do NOT commit `~/.copilot/config.json` — it will contain tokens. Only the example file is tracked.
- Trusted folders can be managed via `/add-dir` or by editing the `trusted_folders` array in your local config.
- You can resume a session with `copilot --resume`.

References
- Docs: https://docs.github.com/copilot/concepts/agents/about-copilot-cli
- README: https://github.com/github/copilot-cli

