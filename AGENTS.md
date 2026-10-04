# Agent Instructions

Two parts: **Global rules** are portable and identical in every project. The **Project profile** holds this repository's facts.
Explicit user instructions override both.
Priorities:
- **HARD**: never violate unless the user explicitly overrides.
- **SHOULD**: the default unless a project-specific reason exists.
- **PREF**: a recommendation; existing conventions win.

<!-- copilot:start -->
## Global rules

### Core (HARD)
- C1 Inspect before editing: read the target code and the closest existing implementation, then follow its patterns.
- C2 Change only what the task requires. No unrelated refactors, renames, reformatting or lint cleanups in untouched code. Report issues instead.
- C3 Never invent API contracts (endpoints, fields, types, nullability) or package APIs. Ask for a real request/response sample; read package source instead of guessing.
- C4 Never add, print, log or commit secrets or tokens. Never copy existing hardcoded credentials.
- C5 Never add, remove or upgrade a dependency without user approval. Reuse existing packages first.
- C6 Never hand-edit generated files (`*.g.dart`, `*.freezed.dart`, DI config, generated agent adapters). Regenerate them.
- C7 Tests: for any task that changes Dart code, ask once up front (or in the plan) "Write/update tests for this change?", unless the user already said. Write tests only after a yes. In non-interactive runs, add no tests and say so in the summary.
- C8 Never silence analyzer diagnostics with `// ignore` unless the file already ignores that rule.
- C9 Before finishing, review your `git diff` against these rules. Report files changed, checks run and their results, checks skipped, and assumptions.

### Git (HARD)
- G1 Pre-existing uncommitted changes belong to the user. Run `git status` before the first edit, and never revert, stash, discard or overwrite those changes. If a file you must edit has unrelated changes, edit around them and mention it.
- G2 No destructive git unless the user explicitly asks: `reset --hard`, `checkout --`/`restore` on files you didn't change, `clean -f`, `push --force`, `rebase`, `commit --amend`, `branch -D`, `stash drop/clear`, history rewrites.
- G3 Commit or push only when asked. Stage explicit paths from this task, never `git add -A` or `git add .`.
- G4 Delete files only when the task requires it, and list deletions in the summary.
- G5 (SHOULD) If a merge conflict or rebase is in progress, stop and report. If regeneration changes files unrelated to your edit, report it; don't revert.

### Architecture (HARD)
- A1 Feature-first layers: `lib/features/<feature>/{data/{datasources,models,repositories}, domain/{repositories,usecases}, presentation/{bloc|cubit,pages,widgets}}`; shared code lives in `lib/core/`. Create only the layers the task needs.
- A2 Dependencies point inward (presentation → domain → data contracts). Widgets never call datasources, repositories or HTTP; domain never imports UI or HTTP packages.
- A3 Domain contracts use data models directly. Create Entity classes only when asked.
- A4 No business logic, API calls, parsing or persistence in widgets. Business, API and shared state lives in a Bloc/Cubit, never in `setState` or widget fields.
<!-- copilot:end -->

### Workflow
1. **Understand** the request. If a skill matches (see Skills), follow it.
2. **Inspect** (C1, G1), in proportion to the task.
3. **Clarify** only what blocks correctness: unknown API contract, ambiguous UX or architecture, a needed dependency, a destructive operation, the test decision (C7). Ask everything in one message; otherwise proceed and state your assumptions.
4. **Plan first** for a new feature, a change to more than 3 files, or a refactor, unless told to proceed: files, approach, test decision.
5. **Implement** the smallest correct change.
6. **Validate** at the matching level (below).
7. **Self-review** the diff (C9).
8. **Summarize.**

**Stop and report** when:
- validation still fails after 2 fix attempts
- the change would conflict with the user's uncommitted work
- the task needs destructive git, a secret, or a new dependency

### Validation levels
Commands are listed in the Project profile. Never run the app or emulators unless asked.

| Level | When | Do |
|---|---|---|
| L0 | Docs, agent config, non-Dart files | Nothing. If `AGENTS.md` or `.agents/rules/` changed, run the agent-config sync check. |
| L1 | Any Dart change | Format changed files, then analyze. No new diagnostics in touched files. |
| L2 | Logic in blocs/cubits, use cases, repositories, utils | L1 + run related tests (if tests exist or were approved) |
| L3 | New feature, model, DI or annotation change | Codegen + L2 for the feature. Check that the generated DI diff contains only expected registrations. |
| L4 | pubspec, assets, fonts, native folders, app bootstrap, or user request | pub get + all tests + debug build |

### Path rules
Before editing matching files, read the rule file, unless its `# ... rules` heading is already in your context.

| Editing | Rule file |
|---|---|
| `lib/**/presentation/**`, `lib/core/widgets/**`, `lib/app.dart` | `.agents/rules/presentation.md` |
| `lib/**/bloc/**`, `lib/**/cubit/**` | `.agents/rules/state-management.md` |
| `lib/**/data/**`, `lib/**/domain/**`, `lib/**/services/**`, `lib/core/unified_api/**`, `lib/core/usecase/**` | `.agents/rules/data-layer.md` |
| `test/**` | `.agents/rules/testing.md` |

### Skills (`.agents/skills/`)
- `flutter-feature`: new feature, endpoint, API integration, or a screen or flow in an existing feature
- `flutter-ui`: build or change screens and widgets, layout, styling, RTL, responsiveness
- `flutter-debug`: bugs, crashes, exceptions, wrong behavior
- `flutter-refactor`: behavior-preserving restructuring and performance work
- `flutter-review`: read-only review of a diff, branch or files
- `flutter-tests`: write or update tests, after the user approves them

### Maintaining agent config
- **Canonical files** (edit only these): `AGENTS.md`, `.agents/rules/*`, `.agents/skills/*`.
- **Generated files** (never edit): `.claude/rules/`, `.cursor/rules/`, `.github/instructions/`, `.github/copilot-instructions.md`.
- After changing canonical files, run the sync. Guide: `docs/agents/README.md`.

---

## Project profile: flutter_template

### Toolchain
Flutter comes from FVM (`.fvmrc`). `flutter` and `dart` are not on PATH, so always prefix `fvm`.

| Task | Command |
|---|---|
| Packages | `fvm flutter pub get` |
| Analyze | `fvm flutter analyze` |
| Format | `fvm dart format <files>` (page width 100 from `analysis_options.yaml`) |
| Tests | `fvm flutter test <paths>` |
| Codegen (freezed, json, injectable) | `fvm dart run build_runner build --delete-conflicting-outputs` |
| Debug build (L4) | `fvm flutter build apk --debug` |
| Agent-config sync | `fvm dart run tool/agents/sync_agent_config.dart` (add `--check` to verify only) |

### Stack map (role → this repo)
| Role | Here |
|---|---|
| State | `flutter_bloc` (Bloc + Cubit); request status enum `RequestStatus` (`lib/core/utils/request_status.dart`) |
| DI | `get_it` + `injectable`: `getIt`, `configureDependencies()` in `lib/core/services/dependencies.dart` |
| Endpoint registry | `ApiVariables` (`lib/core/unified_api/api_variables.dart`) |
| HTTP client | `ApiClient` wrapping Dio (`lib/core/unified_api/dio/api_client.dart`) |
| Datasource wrapper | `HandlingApiManager.wrapHandlingApi` (`lib/core/unified_api/error/api_handeler_manager.dart`) |
| Repository wrapper | `HandlingException.wrapHandling` → `Either<Failure, T>` (dartz) (`error_handeler.dart`, `failure.dart`) |
| Use case base | `UseCase<T, Params>`, `NoParams` (`lib/core/usecase/usecase.dart`) |
| Models | freezed + json_serializable, top-level `<name>FromJson(String)` |
| Theme | `AppTheme` colors, `spacing*`, `radius*`, `elevation*`, `animation*` (`lib/core/theme/app_theme.dart`); `context.theme`, `context.textTheme` (`lib/core/extensions/context_extensions.dart`) |
| Sizing and breakpoints | `flutter_screenutil` `.w/.h/.sp/.r` (design size 390×844); `context.isPhone/isTablet/isDesktop` |
| Shared widgets | `lib/core/widgets/`: `MainButton`, `MainTextField`, `MainAppBar`, `MainErrorWidget`, `YesNoDialog`, `IconConfirmationDialog`, `CustomDropDownWithSearch`, `LocalizedDatePicker`, `FrameworkErrorFallback` |
| Toasts and loading | `Toaster` (bot_toast) in `lib/core/utils/toaster.dart` |
| Localization | `easy_localization` (`'key'.tr()`); `assets/translations/{ar,en}.json`; Arabic-first RTL (start locale `ar`) |
| Navigation | Imperative `Navigator` (no router package) |
| Storage and logging | `flutter_secure_storage` (provided by DI); `dart:developer` `log`, `logger` (Dio interceptor) |
| Tests | None yet. `mocktail` is available; `bloc_test` is not installed (ask before adding). Widget tests need `ScreenUtilInit` above the widget. |

### Conventions and decisions
- **Copy this feature:** `lib/features/asmaa_allah/`.
- **Legacy, don't copy** (details in `docs/agents/known-issues.md`):
  - the `lib/features/update/` layout (`model/`, `services/`, a cubit using `http` and `Toaster`)
  - `lib/features/counter/domain/entities/`
  - `Widget _buildX()` methods in `update_screen.dart`
  - hardcoded colors and fonts in `asmaa_allah_screen.dart`
  - `bloc: getIt<X>()` combined with `context.read<X>()`
- **Bloc provision:**
  - Existing Blocs are `@lazySingleton`: provide them with `BlocProvider.value(value: getIt<X>())`.
  - New screen-scoped Blocs: `@injectable` + `BlocProvider(create: (_) => getIt<X>())`.
- **Imports:** the style is mixed (`package:` vs relative). Match the file you edit.
- **Misspelled names:** don't rename `error_handeler.dart`, `api_handeler_manager.dart`, `eleavation` or `RECIEVE_TIMEOUT` unless asked.
- **Analyzer baseline** (2026-09-13): 88 pre-existing issues (mostly deprecated `withOpacity`). Don't fix unrelated ones.
