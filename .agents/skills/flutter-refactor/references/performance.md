# Flutter performance workflow

Source: https://docs.flutter.dev/perf/best-practices

## 1. Measure first
- Use profile mode on a real device (`flutter run --profile`), only when the user agrees to run the app. Debug mode is not representative.
- In DevTools:
  - **Performance** view: frame times (budget 16 ms, or 8 ms on 120 Hz)
  - **Rebuild stats**: which widgets rebuild
  - **Track layouts**: intrinsic passes
- If running isn't possible, reason from the code and label the conclusions "unmeasured".

## 2. Fix in this order
1. **Rebuild scope**:
   - builders wrapping large subtrees → `BlocSelector`/`buildWhen`, or push the builder down
   - `MediaQuery.of(context)` → `MediaQuery.sizeOf(context)` (or `paddingOf`, etc.)
   - `context.watch` high in the tree → a selector
   - `setState` high in the tree → move state down or use `ValueNotifier`
   - pass static subtrees via the builder's `child`
   - add `const`
2. **Build cost**: move sorting, filtering, parsing, date/number formatting and regex out of `build()`, into the Bloc/Cubit or cached fields. Don't create controllers, `TextStyle`s or `Paint`s per build when they can be constants.
3. **Lists and grids**:
   - `ListView.builder`/`.separated` instead of `Column` + `map`
   - stable `Key`s for reorderable or animated items
   - avoid `shrinkWrap: true` inside scrollables on long lists (use slivers)
   - set `itemExtent`/`prototypeItem` for fixed-height items
4. **Images**:
   - set `cacheWidth`/`cacheHeight` to the displayed size
   - use `FadeInImage` instead of animating `Opacity`
   - reuse the project's image caching if it has one; ask before adding a package
5. **Paint and compositing**:
   - avoid the `Opacity` widget (use translucent colors, or `FadeTransition`/`AnimatedOpacity` for animation)
   - prefer `borderRadius` over `ClipRRect`
   - avoid `Clip.antiAliasWithSaveLayer`
   - use `RepaintBoundary` only when measurement shows isolated repaints help
6. **Layout**: avoid intrinsic passes (`IntrinsicHeight/Width`, shrink-wrapped grids); give cells fixed or anchored sizes.
7. **Animations**:
   - animate only the changing subtree (`AnimatedBuilder` with `child`)
   - dispose controllers
   - don't chain many simultaneous heavy effects on large widgets
8. **Network and async**:
   - no repeated fetches on rebuild (dispatch in `create`/`initState`)
   - debounce search-as-you-type
   - cancel stale requests where the client supports it

## 3. Verify
Re-measure with the same scenario. Report before and after numbers, or state that the change is unmeasured.
