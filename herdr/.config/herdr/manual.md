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

The mouse can also switch workspaces, tabs, and panes.

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
