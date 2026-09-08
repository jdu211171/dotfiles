# Development Guidelines

This document contains comprehensive guidelines for development workflows, git practices, and code quality standards.

## Core Development Principles

### Development Standards
1. **Prioritize simplicity and readability** over clever solutions
2. **Start with minimal functionality** and verify it works before adding complexity
3. **Follow existing patterns exactly** - Study how the project structures similar code
4. **Maintain consistency** - Use the project's naming conventions, style (indentation, naming, patterns)
5. **Check dependencies first** - Never assume a library is available
6. **Security first** - Never expose secrets or keys in code

### Code Quality Standards
1. Handle errors properly and validate inputs
2. Write self-documenting code with type safety
3. Make small, testable incremental changes
4. Address code duplication proactively
5. When fixing issues, check for similar problems elsewhere
6. Document recurring issues in TODO.md

### Essential DO NOT Rules
- Create documentation files unless explicitly requested
- Modify reference repositories
- Make up performance numbers or generic justifications for changes
- Assume libraries are available without checking

### Essential ALWAYS Rules
- Check if repositories are already cloned locally
- Work in designated workspace directories for modifications
- Use existing benchmark infrastructure
- Follow project patterns and conventions
- Measure performance changes properly
- Let improvements stand on their technical merit
- Read relevant documentation before starting tasks

## Project Management

### TODO.md as Development Log
1. **Maintain `TODO.md` as central development log** and task tracker
2. Include:
   - Current/upcoming tasks (with checkboxes)
   - Recurring issues and their solutions
3. Update when: starting tasks, making progress, completing tasks, encountering issues
4. Check at start of each session

### Session Start Checklist
1. Check `TODO.md` for current state and development log
2. Run `git status` to see uncommitted changes
3. Run code tracking commands (see Maintenance section)
4. Review recent commits: `git log --oneline -5`
5. Check for outdated dependencies (if applicable)

### Debugging and Logging
1. Remove console.log statements before committing
2. Clean up debug output before production

## Git and Version Control Workflow

### Git Usage for Solo Development
1. Create git repo for each project with .gitignore
2. Work directly on main branch (no need for feature branches with multiple AI agents sharing same filesystem)
3. Keep main branch stable and deployable
4. Commit regularly on user permission to track changes and enable rollback

### Git Worktree Workflow (For Feature Development)
Git worktrees allow multiple working directories from a single repository, perfect for parallel work.

```bash
git branch feature/FEATURE-PURPOSE
git worktree add ../FEATURE-PURPOSE
cd ~/Development/FEATURE-PURPOSE
```

Use descriptive worktree names:
- `reth-cpu-optimization`
- `repo-name-issue-123`
- `project-feature-description`

Benefits:
- Keep multiple experiments running in parallel
- Easier cleanup - just remove the worktree directory

After finishing task, on user request create pull request and remove the worktree.

### Working Directory Guidelines
1. Use git worktrees for creating isolated workspaces from existing repos
2. Create feature branches for your work: `name/fix-something`, `name/add-feature`
3. Before committing: run lint/build checks and verify functionality

## Commit Message Guidelines

### Commit Title Format
Use semantic commit format with clear, specific titles:
- `feat:` - New features
- `fix:` - Bug fixes  
- `perf:` - Performance improvements
- `chore:` - Maintenance tasks
- `docs:` - Documentation
- `test:` - Test changes
- `refactor:` - Code restructuring

**Title guidelines**:
- Be specific: `perf: add specialized multiplication for 8 limbs` not `perf: optimize mul`
- Use imperative mood: "add" not "adds" or "added"
- Keep under 50 characters when possible
- Don't end with a period

### Commit Description (Body)
The commit body provides context about a specific commit.

**When to add a body**:
- Breaking changes (note the impact)
- Non-obvious changes (explain why, not what)
- Complex changes that cannot be split up

**Format**:
```
<title line>
<blank line>
<body>
<blank line>
<footer>
```

### Commit Examples

**Performance improvement**:
```
perf: add specialized multiplication for 8 limbs

Benchmarks show ~2.7x speedup for 512-bit operations:
- Before: ~41ns
- After: ~15ns

This follows the existing pattern of specialized implementations
for sizes 1-4, extending to size 8 which is commonly used.
```

**Bug fix**:
```
fix: correct carry propagation in uint addition

The carry bit was not properly propagated when the first limb
overflowed but subsequent limbs were at MAX-1. This caused
incorrect results for specific input patterns.

Added test case that reproduces the issue.
```

**Simple feature** (title often sufficient):
```
feat: add From<u128> implementation for Uint<256>
```

### Key Commit Principles
1. The title should make sense in a changelog
2. The body should explain why this change was necessary
3. Include concrete measurements for performance claims
4. Reference issues when fixing bugs: `Fixes #12345`
5. Match detail to complexity - simple changes need simple descriptions

### CRITICAL: Never Make Up Measurements
**NEVER include performance numbers unless you have actually measured them!**

Bad (made-up numbers):
```
perf: optimize trie lookups

~3x faster on mainnet blocks
- Before: 120ms
- After: 40ms
```

Good (only what you measured):
```
perf: optimize trie lookups

Benchmarked with `cargo bench trie_lookup`:
- Before: 120ms
- After: 40ms
```

Also Good (no numbers if not measured):
```
perf: optimize trie lookups by caching decoded nodes

Previous implementation decoded nodes on every access.
Now maintains decoded cache with LRU eviction.
```

## Pull Request Guidelines

### Core PR Principles
1. **Be descriptive but concise** - Include what reviewers need, nothing more
2. **Explain what and why** - Help reviewers understand the changes and motivation
3. **Include real measurements** - Only include numbers you've actually measured
4. **Link related work** - Reference issues, discussions, and dependencies
5. **Write well** - Use flowing prose, not bullet points

### PR Title
Clear, specific titles that make the purpose obvious:
- `feat: add state provider metrics`
- `fix: correct modexp edge case handling`
- `perf: optimize reserve_nodes allocation`

### PR Body Examples

**Bug fix with context**:
```
The validator was incorrectly handling empty block bodies, causing panics
during sync. Fixed by adding proper bounds checking before accessing block data.

Fixes #12345
```

**Performance with evidence**:
```
Previously `reserve_nodes` took ~30% of time in revealing

Main profile: https://share.firefox.dev/3S18zep
After: https://share.firefox.dev/4T29afq
```

**Feature with explanation**:
```
State access during EVM execution was a black box - we had no visibility into
where time was spent. Now we track fetch times for storage slots, account data,
and contract code throughout block processing.

The metrics use our existing prometheus infrastructure and are exposed on the 
standard metrics endpoint. They're sampled at 10% by default to minimize overhead,
configurable via `--metrics-sample-rate`.
```

### When More Detail is Needed
Some PRs benefit from comprehensive descriptions:
1. Performance improvements - Include benchmarks, profiles, and methodology
2. Breaking changes - Explain what breaks and migration path
3. Complex features - Describe architecture and design decisions
4. Bug fixes for subtle issues - Explain root cause and fix approach
5. External context - Link to discussions, RFCs, or design docs

### Writing Quality Matters
Use complete sentences that flow naturally. Avoid bullet-point lists when prose would be more effective. Scale detail to match complexity.

### Important PR Notes
- Always add `stoicist` as reviewer when creating PRs
- NEVER mention co-authored-by or the tool used to create the commit/PR

## GitHub CLI Usage
The `gh` CLI tool is available for exploring GitHub repositories and understanding code context.

## Development Workflow

### Planning and Implementation
1. Discuss approach and evaluate pros/cons before coding
2. Make small, testable incremental changes
3. Address code duplication proactively
4. When fixing issues, check for similar problems elsewhere
5. Document recurring issues in TODO.md

### Before Committing
1. Run git status to check changes
2. Run formatters before type checks
3. Run lint/build checks
4. Verify functionality
5. Keep changes minimal

## Project-Specific Guidelines

### Folder Structure Documentation
Document the project's specific folder structure in the ./AGENTS.md file for future use, instead of checking it everytime, including:
1. Where components live
2. API route organization
3. Utility function locations
4. Type definition structure
5. Asset management
