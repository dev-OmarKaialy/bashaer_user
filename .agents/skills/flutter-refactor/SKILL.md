---
name: flutter-refactor
description: Performs behavior-preserving refactors and performance optimization in Flutter apps, including extracting widgets from large build methods or helper methods, narrowing rebuild scope, moving logic out of widgets into Blocs, removing duplication, simplifying code, and fixing jank or excessive rebuilds with measurement. Use when the user asks to refactor, clean up, restructure, extract, simplify, deduplicate, optimize, speed up, or fix performance or jank.
---
# Refactor or optimize

Follow AGENTS.md. Read the rule files for the paths involved. Also read `docs/agents/known-issues.md` if it exists; it may already describe the problem.

## Inputs
- The target code and the goal (readability, structure, performance).
- Scope confirmation: the exact files or areas that may change.
- The test decision (C7). Safety-net tests are recommended when logic moves.

## Steps
1. **Record current behavior**: public API, inputs and outputs, emitted states, visible UI, side effects. This is the contract to preserve.
2. **Confirm scope**: list the files you'll change. If the refactor needs changes outside that list, ask first (G5).
3. **Plan small steps**, each leaving the code compiling, e.g.:
   1. extract widget classes
   2. move logic into the Bloc
   3. narrow the builders
   4. delete dead code the refactor made unused
4. **Performance work** only: follow [references/performance.md](references/performance.md), and measure before and after.
5. **Execute step by step**, running the analyzer after each step. Keep public names and file paths unless renaming is the requested goal.
6. **Validate** at L2 (L3 if DI or models changed), and confirm the recorded behavior is unchanged.
7. **Self-review** the diff for accidental behavior changes: conditions, defaults, ordering of emits, dispose calls.

## Checklist
- [ ] Behavior unchanged, and how that was verified
- [ ] No scope creep; no renames or new dependencies unless requested (C2, C5)
- [ ] No new helper-method builders, no widened rebuild scope, no new `setState` for business state (F4, F5, A4)
- [ ] Removed code was actually unused (search for references before deleting)

## Output
- Before and after structure (short)
- Files changed
- Behavior-preservation evidence (tests, analyzer, reasoning)
- Measurements, for performance work
- Follow-ups not done
