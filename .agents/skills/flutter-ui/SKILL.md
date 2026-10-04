---
name: flutter-ui
description: Builds or changes Flutter screens and widgets from a description, screenshot or design, covering widget decomposition, reuse of shared widgets and theme tokens, local UI state, scoped rebuilds, loading/error/empty states, RTL, responsiveness and accessibility. Use for UI-only work such as a new screen layout, restyling, a new widget, layout fixes, design implementation, RTL or responsive adjustments.
---
# Build or change UI

Follow AGENTS.md. Read `.agents/rules/presentation.md` unless its heading is already in context. If Bloc state must change, also read `.agents/rules/state-management.md`.

## Inputs
- A description, screenshot or design, and the target screen or feature.
- Which states the screen must show.
- The test decision (C7), if Dart logic changes beyond layout.

## Steps
1. **Inspect**:
   - the target screen and its Bloc state
   - `lib/core/widgets/` and the feature's `presentation/widgets/`
   - theme tokens and context extensions (Project profile)
   - one similar existing screen, for look and structure
2. **Decompose** the design into a widget tree, splitting by *how each part changes*: static, driven by Bloc state, or driven by local UI state. Name each extracted widget class.
3. **Map to what exists**. For every piece, choose one: reuse a shared widget, parameterize an existing one, or create a new one (feature-level unless 2 or more features need it) (F7).
4. **Decide where state lives**. Business or API data goes in a Bloc/Cubit (A4). Ephemeral UI state goes in an owned `ValueNotifier` (F1). If Bloc or data changes are genuinely needed, say so and confirm before touching those layers.
5. **Implement** widget classes (F4) with `const` constructors and the smallest builders (F5), styled with tokens (F10) and the project sizing system (F11).
6. **Cover the screen states**: initial, loading, error, empty, data (F8).
7. **Check**:
   - RTL: directional paddings and alignments (F12)
   - localized strings (F13)
   - text scaling and small widths: no fixed heights around text, no overflow
   - semantics labels and tap targets (F14)
8. **Validate** at L1 (L2 if Bloc logic changed). Self-review the diff, then summarize.

## Checklist
- [ ] No business logic or API or business state in widgets (A4)
- [ ] No new `Widget _buildX()` methods; no new hex or `Colors.*` literals (F4, F10)
- [ ] Rebuild scope is minimal; static parts are `const` (F5)
- [ ] Owned notifiers and controllers are disposed (F2)
- [ ] Shared widgets reused; new widgets placed correctly (F7)
- [ ] All screen states, RTL, localization, accessibility covered (F8, F12–F14)
- [ ] Data and domain layers untouched unless confirmed

## Output
A summary covering:
- the widget tree (new vs reused widgets)
- where state lives
- files changed
- validation results
- anything that couldn't be matched exactly to the design
