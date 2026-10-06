Before every shell command invocation, add a concise shell comment on its own line using `# intent: <purpose>`. Keep the comment in the same invocation as the command so Atuin records its purpose with the command. Describe the action, not its expected result. For multiple related commands in one invocation, add a comment before each logical group; do not combine unrelated commands under one vague comment. Keep comments short and searchable; never put secrets in a comment. This applies to shell commands only, not other tools or API calls.

Example:

```sh
# intent: inspect repository changes
git status --short --branch
```
