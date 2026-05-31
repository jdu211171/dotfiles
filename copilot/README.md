# GitHub Copilot CLI

This package manages GitHub Copilot CLI configuration using GNU Stow, following the repository's security guidelines.

## 📁 Managed Files

**Tracked** (version controlled):
- `config.json` - Main Copilot CLI settings (theme, beep, markdown rendering, trusted folders)
- `mcp-config.json` - Model Context Protocol (MCP) server configurations
- `config.json.example` - Template with accessible defaults (no tokens)

**Ignored** (not tracked via `.stow-local-ignore`):
- `session-state/` - Session state files (transient)
- `history-session-state/` - History state files (transient)
- `command-history-state.json` - Command history (32KB+, frequently changing)
- `logs/` - Log files (noisy)

## 🚀 Installation

Apply this configuration using GNU Stow:

```bash
cd ~/dotfiles
stow copilot
```

Or use the Makefile:
```bash
make stow PACKAGES="copilot"
```

This creates symlinks:
- `~/.copilot/config.json` → `~/dotfiles/copilot/.copilot/config.json`
- `~/.copilot/mcp-config.json` → `~/dotfiles/copilot/.copilot/mcp-config.json`

## 📝 Configuration Details

### config.json

Main Copilot CLI preferences:
- **banner**: Show banner on startup (`always`, `never`, `once`)
- **beep**: Audio feedback for commands
- **render_markdown**: Render markdown in terminal
- **screen_reader**: Optimize for screen readers
- **theme**: UI theme (`auto`, `light`, `dark`)
- **trusted_folders**: Directories where Copilot can execute commands
- **stream**: Stream responses as they arrive
- **parallel_tool_execution**: Enable concurrent tool execution

### mcp-config.json

MCP server configurations for extending Copilot capabilities:
- **context7**: HTTP-based context provider (https://mcp.context7.com)
- **playwright**: Browser automation via npx (@playwright/mcp)
- **chrome-devtools**: Chrome DevTools integration via npx

## 🔄 Usage

### Add a Trusted Folder

Use the CLI command:
```bash
copilot
/add-dir /path/to/project
```

Or edit `config.json` directly:
```json
{
  "trusted_folders": [
    "/Users/username/Development/new-project"
  ]
}
```

### Add an MCP Server

Edit `mcp-config.json`:
```json
{
  "mcpServers": {
    "my-server": {
      "command": "npx",
      "args": ["my-mcp-server@latest"],
      "tools": ["*"]
    }
  }
}
```

### Resume a Session

```bash
copilot --resume
```

## 🔍 Troubleshooting

### Check Current Configuration

```bash
cat ~/.copilot/config.json
cat ~/.copilot/mcp-config.json
```

### Verify Symlinks

```bash
ls -la ~/.copilot/*.json
```

Should show symlinks pointing to `~/dotfiles/copilot/.copilot/`

### View Logs

```bash
ls -lt ~/.copilot/logs/ | head
```

## 🔐 Security Note

- The `trusted_folders` setting is critical for security
- Only add directories where you trust Copilot to execute commands
- Do NOT commit authentication tokens or sensitive data

## 📚 References

- [Copilot CLI Docs](https://docs.github.com/copilot/concepts/agents/about-copilot-cli)
- [GitHub Copilot CLI](https://github.com/github/copilot-cli)
