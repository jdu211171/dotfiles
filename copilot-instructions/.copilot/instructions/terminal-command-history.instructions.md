Before every shell command invocation, add a concise shell comment on its own line using `# intent: <purpose>`. Keep the comment in the same invocation as the command so Atuin records its purpose with the command. Describe the action, not its expected result. For multiple related commands in one invocation, add a comment before each logical group; do not combine unrelated commands under one vague comment. Keep comments short and searchable; never put secrets in a comment. This applies to shell commands only, not other tools or API calls.

## Response and Documentation Style
- Use active voice.
- Limit each prose sentence to 20 words.
- Put one idea in each sentence.
- Use the same term for the same concept throughout each response or document.
- Use plain language. Avoid idioms, metaphors, and unnecessary jargon.
- Define technical terms when readers may not know them.
- Keep code comments short. State purpose, behavior, constraints, and non-obvious reasons directly.
- Keep technical documentation precise. State requirements, steps, expected results, and failure conditions.
- Use natural wording. Remove filler and repeated conclusions.
- Preserve exact syntax, identifiers, command names, logs, quotations, and code examples.

Example:

```sh
# intent: inspect repository changes
git status --short --branch
```
