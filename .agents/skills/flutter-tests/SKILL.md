---
name: flutter-tests
description: Writes or updates Flutter/Dart tests (unit tests for use cases and repositories, Bloc/Cubit state-sequence tests, widget tests for screen states) using fakes and the project's existing mocking library. Use only after the user has approved writing tests for the current task, or when the user explicitly asks to write, add or fix tests or improve coverage.
---
# Write tests

Follow AGENTS.md. Read `.agents/rules/testing.md` unless its heading is already in context.
Precondition: the user approved tests for this task (C7). If not, ask first.

## Inputs
- The code under test, and the behaviors or cases to cover.
- Existing tests nearby (reuse their helpers and fakes).

## Steps
1. **Inspect** the existing `test/` structure, helpers and `dev_dependencies`. Mirror `lib/` paths (T3).
2. **List the cases** before writing: success, each failure type, empty data, edge values, and for UI the loading, error, empty and data states.
3. **Choose doubles**: hand-written fakes for repositories and datasources; the existing mocking library for third-party classes (e.g. the HTTP client, secure storage). Ask before adding a test package (T5).
4. **Write tests** from [references/test-templates.md](references/test-templates.md), priority as in T4. One behavior per test (T6).
5. **Run** only the new or affected test files (T8), and fix failures in the tests. If a failure reveals a production bug, report it; don't patch production code silently (T2).
6. **Validate** at L2. Self-review the diff.

## Output
- Test files added or changed, and the cases covered
- Test run results
- Production bugs found (not fixed unless asked)
- Untested areas worth covering next
