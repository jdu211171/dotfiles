---
inclusion: always
---

# Searchable Terminal History

- Before every shell command invocation, add a concise shell comment on its own line using `# intent: <purpose>`. Keep it in the same invocation as the command so Atuin records the purpose with the command.
- Describe the action, not its expected result. For multiple related commands in one invocation, add a comment before each logical group; don't combine unrelated commands under one vague comment.
- Example:

  ```sh
  # intent: inspect repository changes
  git status --short --branch
  ```

- Keep comments short and searchable. Never put secrets in a comment. This applies to shell commands only, not other tools or API calls.
