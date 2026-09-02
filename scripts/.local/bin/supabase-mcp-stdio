#!/usr/bin/env bash
set -euo pipefail

# Wrapper to launch Supabase MCP server via npx for stdio transport,
# ensuring SUPABASE_ACCESS_TOKEN is present (loaded from ~/.mcp-auth/supabase.env if needed).

if [[ -z "${SUPABASE_ACCESS_TOKEN:-}" ]]; then
  if [[ -f "$HOME/.mcp-auth/supabase.env" ]]; then
    set -a
    # shellcheck source=/dev/null
    . "$HOME/.mcp-auth/supabase.env"
    set +a
  fi
fi

if [[ -z "${SUPABASE_ACCESS_TOKEN:-}" ]]; then
  echo "error: SUPABASE_ACCESS_TOKEN is not set; populate $HOME/.mcp-auth/supabase.env" >&2
  exit 1
fi

exec npx -y @supabase/mcp-server-supabase@latest "$@"

