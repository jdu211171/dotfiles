# Restore Codex configuration safely with GNU Stow

This repository stores the stable Codex configuration in `codex/.codex/`. GNU Stow places that package at `~/.codex` without requiring Codex authentication to be copied into Git.

## Important safety rules

- Do not run `stow -D codex` when restoring the configuration.
- Do not delete `~/.codex/auth.json`, sign out of Codex, or revoke credentials.
- Do not add `auth.json`, session history, logs, databases, or other runtime state to Git.
- Run the dry-run first and stop if Stow reports a conflict with a real file.

The repository's ignore rules exclude Codex authentication and runtime files from Stow/Git handling. The configuration file is safe to track; authentication remains local.

## Restore or update the Codex package

```sh
cd ~/dotfiles

# Confirm the package and target before changing anything.
make dry-run PACKAGES="codex"

# Record only the authentication file's metadata hash; do not print its contents.
auth_file="$HOME/.codex/auth.json"
auth_hash_before=""
if [ -f "$auth_file" ]; then
  auth_hash_before="$(shasum -a 256 "$auth_file" | awk '{print $1}')"
fi

# Re-apply the package. This updates Stow-managed links and does not log out or revoke Codex.
make restow PACKAGES="codex"

# Verify that an existing authentication file is still present and unchanged.
if [ -n "$auth_hash_before" ]; then
  test -f "$auth_file"
  auth_hash_after="$(shasum -a 256 "$auth_file" | awk '{print $1}')"
  test "$auth_hash_before" = "$auth_hash_after"
  echo "Codex authentication file preserved."
fi

ls -ld "$HOME/.codex" "$HOME/.codex/config.toml"
```

If the dry-run reports an existing non-symlink conflict, stop and inspect that path. Move the local configuration into the matching dotfiles package only after confirming that it contains no credentials, then run the dry-run again. Never move or commit `auth.json`.

## Verify the configuration

Restart Codex and confirm the startup warning about unrecognized settings is gone. The current configuration uses:

```toml
approval_policy = "never"
sandbox_mode = "danger-full-access"
```

The obsolete `default_profile`, top-level `network_access`, and `[profiles.full-auto-mode]` settings should not be reintroduced. If a restricted workspace-write profile is used instead, network access belongs under `[sandbox_workspace_write]` or a current `[permissions.<name>.network]` profile, depending on the selected configuration model.
