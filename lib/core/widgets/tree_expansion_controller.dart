import 'package:flutter/foundation.dart';

/// Signals all tree nodes to expand or collapse in bulk.
///
/// Usage:
/// ```dart
/// final controller = TreeExpansionController();
/// // Pass to tree cards:
/// ExpansionTreeCard(tree: root, expansionController: controller);
/// // Toggle from an app-bar button:
/// controller.toggle(); // or expandAll() / collapseAll()
/// ```
class TreeExpansionController extends ChangeNotifier {
  bool _expanded = false;

  /// Whether the last bulk command was "expand all".
  bool get isExpanded => _expanded;

  /// Expand every node.
  void expandAll() {
    _expanded = true;
    notifyListeners();
  }

  /// Collapse every node back to roots only.
  void collapseAll() {
    _expanded = false;
    notifyListeners();
  }

  /// Toggle between expand-all and collapse-all.
  void toggle() {
    _expanded ? collapseAll() : expandAll();
  }
}
