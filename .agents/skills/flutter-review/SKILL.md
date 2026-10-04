---
name: flutter-review
description: Read-only code review of Flutter/Dart changes (working-tree diff, commits, branch or given files) against the project's agent rules, covering correctness, async and state safety, architecture boundaries, UI rules, security and scope. Produces severity-ranked findings with rule IDs. Use when the user asks to review, audit or check changes, a commit, a branch, a PR or specific files.
---
# Review changes

Follow AGENTS.md. Stay **read-only**: don't edit files unless the user asks for fixes afterwards.

## Inputs
- The target:
  - no target: `git diff` + `git diff --staged`
  - a commit: `git show <sha>`
  - a branch: `git diff <base>...HEAD`
  - otherwise, the given paths
- Optional focus (e.g. performance, security).

## Steps
1. **Collect** the diff and the list of changed files. For each hunk, read enough surrounding code to judge it.
2. **Load the rules** for the changed paths (AGENTS.md → Path rules). Load `docs/agents/known-issues.md` if it exists, so legacy problems aren't reported as new.
3. **Check, in this order**:
   1. HARD rules: C, G, A, and the HARD items in D/S/F/T
   2. correctness: null safety, async gaps, emit safety, provider availability, disposal, error paths, edge cases (empty, zero, RTL, long text)
   3. security: secrets, token logging, unsafe input handling
   4. architecture fit: layer placement, reuse of existing code, no unnecessary abstractions or dependencies
   5. SHOULD rules, then PREF
   6. scope: unrelated changes, generated files hand-edited or not regenerated
4. **Run** the analyzer (Project profile) and report only diagnostics in changed lines.
5. **Verify each finding** against the code before reporting it; drop anything speculative.

## Output
| Severity | Location | Rule | Problem | Suggested fix |
|---|---|---|---|---|
| blocker / major / minor / nit | `path:line` | e.g. S6 | … | … |

Severity guide:
- **blocker**: a HARD violation or crash risk
- **major**: a likely bug, or an architecture break
- **minor**: a SHOULD violation
- **nit**: PREF or style

End with what looks good, and a one-line verdict (ready / needs changes).
