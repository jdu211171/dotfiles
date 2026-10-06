# Self-hosted Atuin sync

This guide covers Atuin sync between the Mac and Linux machines, including how to review and clean up AI-run commands.

## Server and account

- Sync URL: `https://ngea.uz/atuin`
- Server and currently documented client version: `18.23.0`
- Client config in this repository: `atuin/.config/atuin/config.toml`
- Registration is closed. The Atuin account already exists; do not register a second account.
- The server stores encrypted sync records in `/var/lib/atuin/atuin.db`. It is not a shared live SQLite file. Each machine keeps its own local Atuin database and syncs records with the server.

Atuin uses an account password and a separate encryption key. Keep the key in a password manager. Never put either credential in Git, a command argument, or chat. Do not run `atuin store rekey` as a casual key rotation: it changes the key used for local records and can make them disagree with records already on the server. [Atuin store reference](https://docs.atuin.sh/18.23/reference/store/)

## Set up another Linux machine

Atuin is included in the Linux package set in `Makefile`. Get the latest dotfiles commit first, then preview and apply the links:

```sh
# intent: update dotfiles
cd ~/dotfiles && git pull

# intent: preview Linux dotfile links
make -C ~/dotfiles dry-run

# intent: install Linux dotfiles, including Atuin configuration
make -C ~/dotfiles stow-os
```

Install Atuin if needed. This installs the client version used by the current server setup:

```sh
# intent: install the Atuin client
curl --proto '=https' --tlsv1.2 -LsSf https://github.com/atuinsh/atuin/releases/download/v18.23.0/atuin-installer.sh | sh
```

Open a new shell so its Atuin integration loads. If this machine has older Bash or Zsh history that has **not** been imported into its local Atuin database, import it once before logging in. Do not repeat the import for the same history file; that can add duplicate entries.

```sh
# intent: import older shell history once, only if it is not already in Atuin
atuin import auto
```

Now log in to the existing account. Atuin prompts for the account password and encryption key. Use the same key as the Mac; do not run `atuin register` on this machine.

```sh
# intent: log in to the existing Atuin account
atuin login -u tukhtamishhojizoda

# intent: sync this machine's Atuin history
atuin sync -f
```

Atuin sync exchanges history records between the machines. It does not replace one machine's local database with another's. Each command keeps its machine context, so the same command run on different machines is not automatically a duplicate. [Atuin sync guide](https://docs.atuin.sh/18.23/guide/sync/)

## Search AI-run commands

Atuin stores supported agent commands with an author tag. The current config keeps AI-authored commands out of the normal **Ctrl-R** results, so they do not swamp everyday shell history. Use the command line to open a picker for agent commands or all commands:

```sh
# intent: search only commands tagged as agent-run
atuin search --author '$all-agent' -- ''

# intent: search commands from Codex
atuin search --author codex -- ''

# intent: search all Atuin commands, including agent-run commands
atuin search --author '' -- ''
```

Atuin's official hooks support Codex, Claude Code, OpenCode, and Pi. After installing a hook, restart that agent. For example, `atuin hook install codex` installs the Codex hook; running it again is safe. Other agents may appear as ordinary shell commands if they run inside an Atuin-integrated shell, but Atuin may not identify them as AI-authored.

Atuin 18.23 does not provide a supported command to change an existing record's author from an agent to a human. Selecting an AI command in the picker does not relabel its saved record. If you put the selected command on your prompt and run it yourself, Atuin records a new human-run entry; the original AI entry remains, so that intentionally creates a second record. Do not rerun commands just to change their label.

If you have reviewed an AI command and want it in the normal Ctrl-R history, search for it with the agent-only command above, put it on the shell prompt, and run it yourself only if it is safe to run again. That creates a human-authored record. If you want only one copy afterward, find the old agent-authored entry, confirm its author in the inspector, and delete that old entry with **Ctrl-O**, then **Ctrl-D**. Deletion syncs to your other machines. This is a manual re-run and delete workflow, not an in-place relabel.

## Clean up history

### Delete an unwanted entry

In the history picker, select the entry, inspect it with **Ctrl-O**, and press **Ctrl-D** only if it is the entry you want removed. Atuin syncs deletions to your other machines. [Atuin deletion guide](https://docs.atuin.sh/18.23/guide/delete-history/)

### Exclude noisy commands going forward

The `history_filter` setting in `atuin/.config/atuin/config.toml` excludes matching command text from future records. It matches the command text, not the AI author, so keep patterns narrow and preview their impact before pruning old history.

To preview and then remove old records matching the configured history and directory filters:

```sh
# intent: preview records matched by configured Atuin exclusion filters
atuin history prune --dry-run

# intent: delete records matched by configured Atuin exclusion filters
atuin history prune
```

Only run the deletion after reviewing the preview. Filtering does not distinguish AI records from human records.

### Find duplicates from a repeated import

Run this only if the same shell history file was imported more than once. Atuin's deduplication matches the same command, working directory, and hostname; repeated commands can be intentional, so inspect the preview. Replace `YYYY-MM-DD` with the cutoff date you want to clean up. The cutoff and number to keep are required.

```sh
# intent: preview duplicate Atuin entries before the chosen cutoff
atuin history dedup --dry-run --before "YYYY-MM-DD" --dupkeep 1

# intent: remove duplicate Atuin entries after reviewing the preview
atuin history dedup --before "YYYY-MM-DD" --dupkeep 1
```

Do not use `atuin store push --force` or `atuin store pull --force` for routine syncing; those options can clear records on one side. Use `atuin sync` for normal syncing. `atuin sync -f` requests a full reconciliation; it is not the same as either destructive store force option.

## Daily use

Automatic sync is enabled in the dotfiles config. To check sync status and sync on demand:

```sh
# intent: check Atuin account and sync status
atuin status

# intent: sync Atuin history now
atuin sync
```

Use **Ctrl-R** for human-authored history. Use the agent search commands above when you want to find commands run by agents. Atuin stores terminal commands, not agent conversations or command output.

If history appears missing, first check that the machine is logged into the same account and uses the same encryption key, then run `atuin sync -f`. Do not re-import the same shell history file as a first troubleshooting step.

## Security and recovery

- Registration is closed. Keep the account password and encryption key private.
- Keep the Atuin database on each client as a local copy. Do not delete the account as a troubleshooting step; account deletion removes server-side history.
- The VPS database is `/var/lib/atuin/atuin.db`. A scheduled server database backup has not been configured.
- Never commit the password, encryption key, or local Atuin data directory.

## References

- [Atuin sync setup](https://docs.atuin.sh/18.23/guide/sync/)
- [Atuin AI agent hooks](https://docs.atuin.sh/18.23/guide/agent-hooks/)
- [Import existing shell history](https://docs.atuin.sh/18.23/guide/import/)
- [Delete and deduplicate history](https://docs.atuin.sh/18.23/guide/delete-history/)
- [Atuin store commands](https://docs.atuin.sh/18.23/reference/store/)
- [Atuin configuration](https://docs.atuin.sh/18.23/configuration/config/)
