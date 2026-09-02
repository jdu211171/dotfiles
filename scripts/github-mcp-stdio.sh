#!/usr/bin/env bash
set -euo pipefail

# Wrapper to launch GitHub MCP server via Docker for stdio transport,
# ensuring env vars are loaded from ~/.mcp-auth/github.env when not already set.

# Load from file if not exported in the parent process
if [[ -z "${GITHUB_PERSONAL_ACCESS_TOKEN:-}" ]]; then
  if [[ -f "$HOME/.mcp-auth/github.env" ]]; then
    set -a
    # shellcheck source=/dev/null
    . "$HOME/.mcp-auth/github.env"
    set +a
  fi
fi

if [[ -z "${GITHUB_PERSONAL_ACCESS_TOKEN:-}" ]]; then
  echo "error: GITHUB_PERSONAL_ACCESS_TOKEN is not set; populate $HOME/.mcp-auth/github.env" >&2
  exit 1
fi

ARGS=(run -i --rm --network host -e GITHUB_PERSONAL_ACCESS_TOKEN)
[[ -n "${GITHUB_HOST:-}" ]] && ARGS+=( -e GITHUB_HOST )

EXTRA=()
case "${GITHUB_READ_ONLY:-}" in 1|true|TRUE|yes|YES) EXTRA+=("--read-only");; esac
case "${GITHUB_DYNAMIC_TOOLSETS:-}" in 1|true|TRUE|yes|YES) EXTRA+=("--dynamic-toolsets");; esac
if [[ -n "${GITHUB_TOOLSETS:-}" ]]; then
  EXTRA+=("--toolsets" "${GITHUB_TOOLSETS}")
fi
gh_host_var="${GH_HOST:-${GITHUB_HOST:-}}"
[[ -n "$gh_host_var" ]] && EXTRA+=( "--gh-host" "$gh_host_var" )

exec docker "${ARGS[@]}" ghcr.io/github/github-mcp-server stdio --log-file /dev/stderr "${EXTRA[@]}" "$@"
