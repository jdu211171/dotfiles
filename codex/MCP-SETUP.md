# MCP Servers Setup for OpenAI Codex CLI

## ✅ Resolution Summary

Fixed the timeout errors for GitHub and Supabase MCP servers by:

1. **Created `~/.mcp-auth/` directory** with secure permissions (700)
2. **Copied environment files** from Downloads to `~/.mcp-auth/`:
   - `github.env` (contains GITHUB_PERSONAL_ACCESS_TOKEN)
   - `supabase.env` (contains SUPABASE_ACCESS_TOKEN)
3. **Copied wrapper scripts** to `~/dotfiles/scripts/`:
   - `github-mcp-stdio.sh` - Launches GitHub MCP via Docker
   - `supabase-mcp-stdio.sh` - Launches Supabase MCP via npx
4. **Updated `config.toml`** to use absolute paths to scripts
5. **Started Docker Desktop** (required for GitHub MCP server)

## 🔧 Configuration Details

### File Locations

```
~/.mcp-auth/
├── github.env          # GitHub PAT (permissions: 600)
└── supabase.env        # Supabase access token (permissions: 600)

~/dotfiles/scripts/
├── github-mcp-stdio.sh     # GitHub MCP wrapper (executable)
└── supabase-mcp-stdio.sh   # Supabase MCP wrapper (executable)

~/dotfiles/codex/.codex/
└── config.toml         # Codex configuration
```

### GitHub MCP Server

- **Transport**: stdio via Docker container
- **Image**: `ghcr.io/github/github-mcp-server`
- **Requirements**: Docker Desktop must be running
- **Token**: GitHub Personal Access Token in `~/.mcp-auth/github.env`
- **Timeout**: 60 seconds (startup)

### Supabase MCP Server

- **Transport**: stdio via npx
- **Package**: `@supabase/mcp-server-supabase@latest`
- **Requirements**: Node.js and npx installed
- **Token**: Supabase access token in `~/.mcp-auth/supabase.env`
- **Timeout**: 60 seconds (startup)

## 🚀 Usage

Simply launch Codex CLI as normal:

```bash
codex
```

Both MCP servers should now start successfully without timeout errors.

## 🔍 Troubleshooting

### GitHub MCP Timeout
- **Check Docker**: `docker ps` - must show running containers
- **Start Docker**: `open -a Docker` or start Docker Desktop manually
- **Verify token**: Check `~/.mcp-auth/github.env` has valid PAT

### Supabase MCP Timeout
- **Check npx**: `npx --version` - must be installed
- **Verify token**: Check `~/.mcp-auth/supabase.env` has valid access token
- **Test manually**: `~/dotfiles/scripts/supabase-mcp-stdio.sh`

### View Logs
Check `~/dotfiles/codex/.codex/log/` for detailed error messages.

## 🔐 Security Notes

- All token files in `~/.mcp-auth/` have permissions set to 600 (owner read/write only)
- **Never commit** `.env` files or tokens to git
- Rotate tokens regularly via:
  - GitHub: https://github.com/settings/tokens
  - Supabase: https://supabase.com/dashboard/account/tokens
