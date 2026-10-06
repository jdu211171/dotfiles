# Self-hosted Atuin sync

This guide explains how to sync Atuin command history between this Mac and Linux machines using the self-hosted server.

## Server and client configuration

- Sync URL: `https://ngea.uz/atuin`
- Server version: `18.23.0`
- Client config: `atuin/.config/atuin/config.toml`
- The dotfiles config enables `auto_sync` and points Atuin at the self-hosted URL.
- The server runs as the `atuin` system user with a SQLite database at `/var/lib/atuin/atuin.db`. It listens on localhost; Nginx serves it over HTTPS.
- Account registration is currently disabled. It will be opened briefly for the first account registration and closed afterward.

Atuin keeps a local history database on each machine and syncs it with the server. The server is not a shared live SQLite file. Atuin encrypts synced history end to end; the server does not get the encryption key. The server still receives account and connection metadata.

## Password and encryption key

There is no Atuin account or password yet. During registration, choose a password when Atuin prompts. Do not pass the password as `-p` or put it in a command, since that can save it in shell history.

Atuin also creates an encryption key. The password and encryption key are separate credentials. Save the key in a password manager or another private place. You need both the password and key to log in on another machine. Never commit or send the key in chat. Atuin cannot recover a lost encryption key.

## Register the first machine and upload its history

Use the Mac where Atuin already has your local history. Registration must be temporarily enabled on the server first; it is disabled now. Once the registration window is open:

1. If you want to include older Zsh history that Atuin has not imported yet, import it once:

   ```sh
   # intent: import older Zsh history not already in Atuin
   atuin import auto
   ```

   Skip this if Atuin already contains the history you want or you have imported that file before.

2. Register your account. Replace the username and email with your own; Atuin prompts for the password securely.

   ```sh
   # intent: register the first account on the self-hosted Atuin server
   atuin register -u YOUR_USERNAME -e YOUR_EMAIL
   ```

3. Display the generated encryption key and store it privately.

   ```sh
   # intent: display the encryption key for secure storage
   atuin key
   ```

4. Upload the Atuin history currently on this Mac.

   ```sh
   # intent: perform the initial full Atuin history sync
   atuin sync -f
   ```

After the account is created, close server registration again. Ask the VPS administrator to do that if it has not already been closed.

Only commands already captured in Atuin are synced. `atuin import auto` can add older shell history. Atuin syncs terminal command history, not agent conversations or command output. The configured secret filter remains enabled, but avoid putting secrets in commands.

## Add another Linux machine

Pull the dotfiles commit and stow the OS package set. Atuin is already included in the Linux defaults in `Makefile`.

```sh
# intent: preview the Linux dotfiles links
make -C ~/dotfiles dry-run

# intent: install the Linux dotfiles, including Atuin configuration
make -C ~/dotfiles stow-os
```

Install Atuin if it is not present. Use the same tagged version as the server unless the server is upgraded too.

```sh
# intent: install the Atuin client version matching the VPS server
curl --proto '=https' --tlsv1.2 -LsSf https://github.com/atuinsh/atuin/releases/download/v18.23.0/atuin-installer.sh | sh
```

Open a new shell after stowing so the shell integration loads. The shared config already points to `https://ngea.uz/atuin`. If this machine has older shell history that is not in its local Atuin database, run `atuin import auto` once before syncing.

Log into the existing account; do not register a second account. Atuin prompts for your password and encryption key.

```sh
# intent: log this Linux machine into the existing Atuin account
atuin login -u YOUR_USERNAME

# intent: sync this machine's Atuin history with the VPS
atuin sync -f
```

The local history on each logged-in machine is merged through sync. Keep each machine's existing Atuin database if it contains history you want to preserve.

## Daily use

Automatic sync is enabled by the dotfiles config. To check the account or sync on demand:

```sh
# intent: check whether this machine is logged into Atuin sync
atuin status

# intent: sync Atuin history now
atuin sync
```

Press **Ctrl-R** in Bash or Zsh to search history. Search for command text, agent names such as `codex`, `agy`, `opencode`, `kiro`, or `grok`, or a distinctive `# intent:` comment if that comment is part of the recorded command. Atuin stores these as terminal commands; it does not index the agent transcript.

If expected history is missing, force a full sync:

```sh
# intent: reconcile the complete local and remote Atuin histories
atuin sync -f
```

## Important security and recovery notes

- The HTTPS endpoint is publicly reachable, but Atuin account registration is disabled except during the first account setup. Keep the account password and encryption key private.
- Keep at least one logged-in machine and the encryption key available. Do not delete the account as a troubleshooting step; deleting it removes the server-side history.
- The server database is `/var/lib/atuin/atuin.db`. A scheduled database backup has not been configured yet. Local Atuin databases remain on each client as additional copies.
- Never put the Atuin password, encryption key, or local Atuin data directory in Git or this dotfiles package.

## References

- [Atuin sync setup](https://docs.atuin.sh/main/guide/sync/)
- [Import existing shell history](https://docs.atuin.sh/main/guide/import/)
- [Atuin account commands](https://docs.atuin.sh/main/reference/account/)
- [Self-hosted server setup](https://docs.atuin.sh/main/self-hosting/server-setup/)
