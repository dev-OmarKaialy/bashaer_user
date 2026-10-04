---
name: flutter-debug
description: Finds the root cause of and fixes bugs in Flutter Bloc/Clean Architecture apps with the smallest correct change, including crashes, exceptions, red screens, wrong or stale UI, stuck loading, failed API calls, DI resolution errors, layout overflows. Use when the user reports a bug, crash, error, exception, stack trace, regression, or something not working as expected.
---
# Debug and fix

Follow AGENTS.md. Read the rule file for the layer where the fault is found (see AGENTS.md → Path rules).

## Inputs
- The symptom: expected vs actual behavior.
- Logs, stack trace or reproduction steps, if available.
- The test decision (C7). A regression test is recommended.

## Steps
1. **Restate** the expected vs actual behavior in one sentence. If you can't reproduce it or locate its trigger from the information given, ask for logs or steps.
2. **Locate the failing layer** by following the data flow: widget → Bloc/Cubit → use case → repository → datasource → API/storage. Read the stack trace from the top app frame.
3. **Check common causes first**:
   - `ProviderNotFoundException`: `context.read<X>()` without an ancestor provider (S12)
   - UI doesn't update: a state field missing from equality, or a mutated collection (S1, S2)
   - spinner never stops: no terminal emit on some path (S6)
   - "emit after close" or "emit was called after an event handler completed" (S7)
   - `use_build_context_synchronously` / deactivated widget ancestor: context used after `await` (F3)
   - "object/factory not registered" in DI: codegen not run, or a missing annotation (D9)
   - JSON type errors or null errors: the model doesn't match the real response (D6)
   - RenderFlex overflow or unbounded constraints: missing `Expanded`/`Flexible`, or scrollables nested without bounds
4. **Confirm the hypothesis** before editing: read the code path, run the analyzer, or run a targeted test. After 2 disproven hypotheses, stop and report your findings with questions.
5. **Fix the root cause** with the smallest change (C2). Don't hide symptoms in the UI while bad data still flows.
6. **Regression test**: only if approved (`flutter-tests` skill).
7. **Validate** at L1 (L2 if logic changed; L3 if DI or models changed). Self-review the diff.

## Output
- Root cause (file:line), and why it happened
- The fix, and the files changed
- Validation results
- Related issues noticed but not fixed
