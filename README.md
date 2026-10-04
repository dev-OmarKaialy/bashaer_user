# Flutter Team Template

Production-oriented Flutter template using:

- Clean Architecture (`data`, `domain`, `presentation`)
- BLoC pattern for state management
- AI coding-agent configuration (Claude Code, Cursor, Codex, Copilot): see `AGENTS.md`
- `get_it` + `injectable` for dependency injection

## Packages used

Core packages included in this template:

- `flutter_bloc`
- `equatable`
- `dartz`
- `get_it`
- `injectable`
- `dio`
- `logger`
- `easy_localization`
- `awesome_notifications`
- `firebase_messaging`

Testing/build packages:

- `flutter_test`
- `mocktail`
- `build_runner`
- `injectable_generator`

## Project architecture

Each feature should follow this structure:

```text
lib/features/<feature_name>/
 data/
  datasources/
  repositories/
 domain/
  entities/
  repositories/
  usecases/
 presentation/
  bloc/
  pages/
```

Reference feature: `features/asmaa_allah` (remote API → datasource → repository → use case → BLoC → screen; data models are used directly in domain contracts). Data models live in `data/models/`, and feature widgets in `presentation/widgets/`.

## DI and startup flow

`lib/main.dart` bootstraps in this order:

1. `WidgetsFlutterBinding.ensureInitialized()`
2. `EasyLocalization.ensureInitialized()`
3. `configureDependencies()` registers everything annotated with `injectable` (generated `lib/core/services/dependencies.config.dart`)
4. `runApp(EasyLocalization(child: TemplateApp()))`

## Team workflow (clone and run)

The Flutter SDK is managed with [FVM](https://fvm.app) (`.fvmrc`):

```bash
fvm flutter pub get
fvm flutter run
```

Run tests:

```bash
fvm flutter test
```

Regenerate code (injectable, freezed, json_serializable) after changing annotations or models:

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

## AI coding agents

`AGENTS.md` holds the shared instructions for Claude Code, Cursor, Codex and GitHub Copilot: global rules, workflow, validation levels, and this project's profile. Path-scoped rules live in `.agents/rules/` and workflow skills in `.agents/skills/`. Agents ask per task whether to write tests.

Maintainer guide (where to add rules, regenerating the tool adapters): `docs/agents/README.md`. Known issues and legacy patterns: `docs/agents/known-issues.md`.
