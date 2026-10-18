# Herdr quick manual

Herdr is the terminal workspace manager replacing tmux for my daily use.
Neovim keeps its normal keybindings, including `Ctrl-h/j/k/l`.

## Start and detach

```bash
herdr
```

Start Herdr or attach to the default session.

```text
Ctrl-b q   Detach and leave everything running
```

Run `herdr` again later to reattach.

If WSL has shut down, Herdr recreates the saved workspace layout and resumes
supported agents in their recorded conversations. This requires the agent's
official Herdr integration; for Codex, install it once with:

```bash
herdr integration install codex
```

The integration records new or resumed Codex session IDs. Codex panes that
were already running when it was installed need to be restarted once before
they can be restored automatically after a WSL shutdown.

### Kiro compatibility

Herdr 0.8.2 detects Kiro but does not ship a Kiro session integration, so Kiro
panes cannot yet be restored automatically from Herdr's session snapshot. To
resume one after WSL shutdown, run the command in its existing pane:

```bash
kiro-cli --v3 --resume-id <session-id>
```

Use Kiro's chat history/session picker to find the ID. Once Herdr adds an
official Kiro integration, enable it with `herdr integration install kiro` and
the `[session]` setting above will cover those panes too.

### Kiro pane restore bridge

This repository includes `kiro-herdr`, a small bridge for the current Herdr
version. It stores Kiro session IDs in the local (ignored) file
`~/.config/herdr/kiro-sessions.tsv` and
recreates them in their Herdr panes:

```sh
kiro-herdr launch w1:p7 /home/user/projects/v2-master --v3
kiro-herdr restore
```

The launcher records the newest Kiro session for the working directory when
Kiro exits. To discover every currently running Kiro pane automatically, run
`kiro-herdr register` with no arguments. Existing sessions can still be added
with `kiro-herdr register <pane> <cwd> <session-id>`. Use `hkr` as the short
restore alias and `hkl` to inspect saved mappings.

## The prefix

Herdr commands use the same prefix as tmux:

```text
Ctrl-b c   New tab
Ctrl-b v   Split right
Ctrl-b -   Split down
Ctrl-b h/j/k/l   Move between panes
Ctrl-b z   Zoom the current pane
Ctrl-b x   Close the current pane
Ctrl-b ?   Show all keybindings
```

## Workspaces

Use one workspace per project or task. Workspaces contain tabs and panes.

```text
Ctrl-b w   Open workspace navigation
Ctrl-b g   Open the workspace picker
```

Herdr reattaches to the existing default session when you run `herdr` again;
it does not automatically create a new workspace for every folder. From a
different project directory, create and focus a workspace there with:

```bash
hnew
```

This is equivalent to creating a workspace using the current directory. New
panes, tabs, and workspaces also use Herdr's launch directory when there is no
source pane to follow.

The mouse can also switch workspaces, tabs, and panes.

## Connect to another laptop

Herdr supports remote machines over SSH. Each laptop has its own Herdr server
and keeps its own sessions and panes. The saved machine profile lives in
Herdr's local client state, not in `config.toml`, so add the profile once on
each computer where you want to connect from. This dotfiles package enables
Herdr's managed SSH keepalives and connection reuse with
`[remote].manage_ssh_config = true`.

First make sure the other laptop is reachable through an SSH host alias in
`~/.ssh/config`. Keep real hostnames, usernames, and key paths in your local
SSH configuration rather than this repository. For example:

```sshconfig
Host workbox
    HostName <laptop-address>
    User <ssh-user>
```

From an interactive terminal on the client laptop, save the machine in
Herdr. Setup can offer to install or update Herdr on the remote laptop and
will ask before doing so:

```sh
# intent: add the SSH host as a saved Herdr machine
herdr machine add workbox

# intent: list saved Herdr machines
herdr machine list
```

After setup, either open a standalone remote client or add the machine to the
current Herdr window and switch to it in the sidebar:

```sh
# intent: attach to the remote Herdr server over SSH
herdr --remote workbox

# intent: check the saved remote machine connection
herdr machine status workbox
```

When running Herdr CLI commands from a local shell or an existing Herdr pane,
select the remote profile explicitly. Otherwise commands keep using the
current pane's Herdr server and socket:

```sh
# intent: list agents on the remote Herdr server
herdr --machine workbox agent list
```

Machine profiles, workspace IDs, pane IDs, and agent names are scoped to each
Herdr server. A local pane ID is not automatically meaningful on the remote
server. Use the remote machine's profile and IDs when routing commands. See
the [official machine connection guide](https://herdr.dev/docs/connecting-machines/)
and [CLI reference](https://herdr.dev/docs/cli-reference/) for more details.

## Named sessions

Named sessions are completely separate Herdr instances. Use them when you
want isolated groups of work.

```bash
hls                 # list sessions
ha work             # attach to (or open) the session named work
hstop work          # stop the session and its processes
hdel work           # delete a stopped session
```

The default session is enough for most work. Prefer workspaces before creating
many named sessions.

## Neovim navigation

Inside Neovim, these keys move between Neovim splits. At an edge, they move
into the neighbouring Herdr pane:

```text
Ctrl-h   Left
Ctrl-j   Down
Ctrl-k   Up
Ctrl-l   Right
```

The same keys move between Herdr panes when the focused pane is not Neovim.

## Useful commands

```bash
herdr status          # show server/client status
herdr session list    # list named sessions
herdr server stop     # stop the default Herdr server
```

`herdr server stop` stops the running panes, so normally use `Ctrl-b q` to
detach instead.

Configuration file: `~/.config/herdr/config.toml`

Official docs: <https://herdr.dev/docs/>
