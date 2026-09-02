#!/usr/bin/env bash
set -euo pipefail

# Wrapper to launch Backlog MCP server via npx for stdio transport,
# ensuring BACKLOG_DOMAIN and BACKLOG_API_KEY are present (loaded from ~/.mcp-auth/backlog.env if needed).

if [[ -z "${BACKLOG_DOMAIN:-}" ]] || [[ -z "${BACKLOG_API_KEY:-}" ]]; then
  if [[ -f "$HOME/.mcp-auth/backlog.env" ]]; then
    set -a
    # shellcheck source=/dev/null
    . "$HOME/.mcp-auth/backlog.env"
    set +a
  fi
fi

if [[ -z "${BACKLOG_DOMAIN:-}" ]]; then
  echo "error: BACKLOG_DOMAIN is not set; populate $HOME/.mcp-auth/backlog.env" >&2
  exit 1
fi

if [[ -z "${BACKLOG_API_KEY:-}" ]]; then
  echo "error: BACKLOG_API_KEY is not set; populate $HOME/.mcp-auth/backlog.env" >&2
  exit 1
fi

exec npx -y backlog-mcp-server "$@"
