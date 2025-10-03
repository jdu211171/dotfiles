# Chrome DevTools MCP for Codex

This repo ships a ready-to-use Model Context Protocol (MCP) server config for Chrome DevTools, wired into the Codex CLI profile.

## Prerequisites

- Node.js v20.19+ and npm available on `PATH`.
- Chrome stable (or Canary/Beta/Dev if you opt in via args).

## Configuration

Codex MCP config lives at `codex/.codex/config.toml`. This repo sets up the Chrome DevTools MCP server via `npx` with auto-confirm, and stdio transport:

```
[mcp_servers.chrome-devtools]
command = "npx"
args = ["-y", "chrome-devtools-mcp@latest"]
startup_timeout_sec = 20
tool_timeout_sec = 60
transport = "stdio"
```

Notes:

- Using `@latest` ensures you get the latest server on each run.
- Add extra args if desired, e.g. `--channel=canary`, `--headless=true`, `--isolated=true`, `--viewport=1280x800`.
- If your MCP client runs Chrome inside a sandbox/container, you may need to pass `--browserUrl` to connect to a Chrome launched outside the sandbox. See: https://developer.chrome.com/docs/devtools/remote-debugging/local-server

## Install and Stow

1) Stow the `codex` package to place `.codex` into your `$HOME`:

```
make stow PACKAGES="codex"
```

2) Ensure prerequisites are installed (Node 20+, Chrome). On Linux, your normal Chrome install is fine.

## Quick Test

From the Codex CLI, try a prompt that uses the browser:

```
Check the performance of https://developers.chrome.com
```

Codex will start the MCP server via `npx`, launch Chrome, record a performance trace, and return insights.

## Troubleshooting

- `npx` prompts or hangs: we pass `-y` in config to auto-confirm package execution. Verify it’s present in `codex/.codex/config.toml`.
- Chrome fails to launch under sandboxed MCP: run Chrome outside the sandbox and connect with `--browserUrl`, or disable sandboxing for this server in your client.
- See upstream docs for more options and help: https://github.com/ChromeDevTools/chrome-devtools-mcp

