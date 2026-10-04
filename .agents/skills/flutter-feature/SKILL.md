---
name: flutter-feature
description: Implements Flutter features end to end in a feature-first Clean Architecture + Bloc/Cubit codebase, including new features, new API endpoints or actions, new screens in existing features, and wiring data, domain, state and UI with dependency injection. Use when the user asks to add, build, implement or integrate a feature, endpoint, API call, screen or user flow.
---
# Implement a feature

Follow AGENTS.md (global rules + Project profile). Read these rule files unless their headings are already in context:
- `.agents/rules/data-layer.md`
- `.agents/rules/state-management.md`
- `.agents/rules/presentation.md` (when UI is involved)

## Inputs
- The goal and the user flow.
- A real request and response sample for every new endpoint (C3, D6). If one is missing, ask before writing the model or datasource.
- The target: a new feature folder or an existing feature.
- The test decision (C7).

## Steps
1. **Classify** the task: new feature, new action in an existing feature, or new screen in an existing feature. For an existing feature, extend its datasource, repository, use cases and Bloc; never create parallel ones.
2. **Inspect**, and stop once you have enough:
   - the canonical feature named in the Project profile (copy its shapes)
   - the endpoint registry, for an existing endpoint
   - the target feature's datasource, repository, use cases, and Bloc events and state
   - shared widgets and theme tokens (for UI)
   - how neighboring classes register with DI
3. **Clarify** in one message: missing contract details, UX ambiguities, any dependency need, the test decision.
4. **Plan** when the task touches more than 3 files or is a new feature, unless told to proceed. List the files to create or modify per layer, plus the test decision.
5. **Implement in this order**, creating only the layers needed. Skeletons are in [references/layer-templates.md](references/layer-templates.md).
   1. endpoint method in the registry
   2. model built from the real sample, then run codegen
   3. datasource (abstract + implementation)
   4. repository (domain contract + data implementation)
   5. use case (+ Params)
   6. Bloc/Cubit: events, state fields (one status per operation), handlers
   7. screen and widgets, with the Bloc provided at the route root
   8. run codegen for DI, then review the generated diff
6. **Tests**: only if approved; then follow the `flutter-tests` skill.
7. **Validate** at level L3 (AGENTS.md).
8. **Self-review** with the checklist below, then summarize.

## Checklist
- [ ] No invented fields or endpoints; endpoint defined only in the registry (C3, D1, D6)
- [ ] Layers and dependency direction respected; no Entity classes (A1–A3, D2–D4)
- [ ] DI bound to abstractions, config regenerated, no manual edits (D9, C6)
- [ ] State immutable with full equality, terminal emits, `isClosed` guards (S1, S6, S7)
- [ ] UI has no logic, scoped rebuilds, widget classes, all screen states (A4, F4, F5, F8)
- [ ] Theme tokens, RTL, localized new strings (F10, F12, F13)
- [ ] No new dependencies without approval; only task files changed (C5, C2, G1)

## Output
A summary covering:
- the flow, from endpoint to screen
- files, grouped by layer
- codegen runs
- validation results
- assumptions and open questions
