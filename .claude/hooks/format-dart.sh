#!/usr/bin/env bash
# PostToolUse hook: format a Dart file after Claude edits it (generated files are skipped).
file=$(jq -r '.tool_input.file_path // empty')
case "$file" in
  *.g.dart | *.freezed.dart | *dependencies.config.dart) exit 0 ;;
  *.dart) ;;
  *) exit 0 ;;
esac
cd "$CLAUDE_PROJECT_DIR" || exit 0
fvm dart format "$file" >/dev/null 2>&1 || true
exit 0
