---
description: Flutter presentation-layer rules for widgets, screens, local UI state, rebuild scope, theming, responsiveness, RTL and accessibility. Apply when creating or editing widgets or screens.
paths:
  - "lib/**/presentation/**"
  - "lib/core/widgets/**"
  - "lib/app.dart"
---
# Presentation rules

AGENTS.md A4 applies: no business logic and no business state in widgets.
Concrete names (theme tokens, shared widgets, sizing, localization) are in AGENTS.md → Project profile.

## Local state and lifecycle
- F1 SHOULD: For small ephemeral UI state (toggle, selected tab, expanded, obscured text), use an owned `ValueNotifier` + `ValueListenableBuilder` instead of `setState`. A `StatefulWidget` is fine for owning lifecycle objects (Animation/TextEditing/Scroll controllers, `FocusNode`, notifiers).
- F2 HARD: Dispose every owned controller, notifier, subscription and timer in `dispose()`. Never create them in `build()`.
- F3 HARD: After an `await`, check `context.mounted` before using `context`.

## Composition and rebuilds
- F4 SHOULD: Extract UI into widget classes (`const` where possible), not `Widget _buildX()` methods. Don't add new helper-method builders, and don't convert existing ones unless asked.
- F5 SHOULD: Rebuild the smallest subtree:
  - `BlocSelector` for one field
  - `BlocBuilder` + `buildWhen` for several fields
  - `BlocListener` for side effects (navigation, dialogs, toasts)
  - `ValueListenableBuilder` for local state

  Never wrap a whole `Scaffold` in a builder when only one section changes. Pass static subtrees through `child`.
- F6 SHOULD: Keep `build()` cheap: no sorting, filtering, parsing or formatting. Use `ListView.builder`/`.separated` for dynamic or long lists.
- F7 SHOULD: Reuse shared widgets before creating new ones. Prefer adding a parameter over cloning a widget, without turning it into a config-driven mega widget. Feature-only widgets go in `presentation/widgets/`; move one to `core/widgets/` only when 2 or more features use it.

## Screens
- F8 SHOULD: Data-driven screens render five states: initial, loading, error (with retry when recoverable), empty, and data. Empty is not an error. Never show raw exceptions to users.
- F9 SHOULD: Provide Blocs at the route root:
  - singleton-registered Blocs: `BlocProvider.value`
  - factory-registered Blocs: `BlocProvider(create:)`

  Dispatch initial events in `create` or `initState`, never in `build()`. Descendants use `context.read` in callbacks.

## Styling, layout, accessibility
- F10 SHOULD: Take colors, text styles, spacing and radii from the theme and project tokens. No new hex or `Colors.*` literals, and no ad-hoc font families, in feature code.
- F11 SHOULD: Use the project's sizing and responsive system; never add a second one. Branch layouts on available size (`MediaQuery.sizeOf`, `LayoutBuilder`, project breakpoints), not on device type. Don't lock orientation.
- F12 SHOULD: Stay RTL-safe: `EdgeInsetsDirectional`, `AlignmentDirectional`, `start`/`end` instead of left/right.
- F13 SHOULD: New user-facing strings go through the project's localization system, with a key added for every supported locale. If the screen you're editing isn't localized yet, ask.
- F14 SHOULD: Icon-only buttons get a `tooltip` or a `Semantics` label. Tap targets are at least 48×48. Don't clip scalable text with fixed heights.
- F15 PREF: Prefer `borderRadius`/decoration over `ClipRRect`, and translucent colors over `Opacity`. Avoid `Clip.antiAliasWithSaveLayer`.

## Example: scoped rebuilds
```dart
Column(
  children: [
    const ProfileHeader(), // static: never rebuilds
    BlocSelector<ProfileBloc, ProfileState, bool>(
      selector: (state) => state.saveStatus.isLoading,
      builder: (context, isLoading) => SaveButton(isLoading: isLoading),
    ),
    ValueListenableBuilder<bool>(
      valueListenable: _expanded, // owned by the State, disposed in dispose()
      builder: (context, expanded, child) => ExpandableSection(expanded: expanded, child: child!),
      child: const BioText(),
    ),
  ],
)
```
