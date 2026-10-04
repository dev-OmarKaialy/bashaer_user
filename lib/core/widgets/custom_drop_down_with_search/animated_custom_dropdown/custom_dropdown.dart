library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../extensions/context_extensions.dart';
import '../../../utils/toaster.dart';

export 'custom_dropdown.dart';

part './dropdown_overlay/dropdown_overlay.dart';
part './dropdown_overlay/overlay_builder.dart';
part './widgets/items_list.dart';
part './widgets/search_field.dart';
part 'animated_section.dart';
part 'dropdown_field.dart';

// const _defaultFillColor = Colors.white;
const _defaultErrorColor = Colors.green;

mixin CustomDropdownListFilter {
  /// Used to filter elements against query on
  /// [CustomDropdown<T>.search] or [CustomDropdown<T>.searchRequest]
  bool filter(String query);
}

const _defaultBorderRadius = BorderRadius.all(Radius.circular(12));

final Border _defaultErrorBorder = Border.all(color: _defaultErrorColor, width: 1.5);

const _defaultHintValue = 'Select value';

typedef _ListItemBuilder<T> = Widget Function(BuildContext context, T item);
typedef _HeaderBuilder<T> = Widget Function(BuildContext context, T selectedItem);
typedef _HintBuilder = Widget Function(BuildContext context, String hint);
typedef _NoResultFoundBuilder = Widget Function(BuildContext context, String text);

class CustomDropdown<T> extends StatefulWidget {
  /// The list of items the user can select.
  final List<T> items;

  /// Initial selected item from the list of [items].
  final T? initialItem;

  /// Text that suggests what sort of data the dropdown represents.
  final String? hintText;

  /// Text that suggests what to search in the search field.
  final String? searchHintText;

  /// Border for closed state of [CustomDropdown].
  final BoxBorder? closedBorder;

  /// Border radius for closed state of [CustomDropdown].
  final BorderRadius? closedBorderRadius;
  final ValueNotifier<List<T>>? multiItemsNotifier;
  final bool multiSelect;

  /// Border for opened/expanded state of [CustomDropdown].
  final BoxBorder? expandedBorder;

  /// Border radius for opened/expanded state of [CustomDropdown].
  final BorderRadius? expandedBorderRadius;

  /// A method that validates the selected item.
  /// Returns an error string to display as per the validation, or null otherwise.
  final String? Function(T?)? validator;

  /// Error border for closed state of [CustomDropdown].
  final BoxBorder? closedErrorBorder;

  /// Error border radius for closed state of [CustomDropdown].
  final BorderRadius? closedErrorBorderRadius;

  /// The style to use for the string returning from [validator].
  final TextStyle? errorStyle;

  /// Enable the validation listener on item change.
  /// This implies to [validator] everytime when the item change.
  final bool validateOnChange;

  /// Suffix icon for closed state of [CustomDropdown].
  final Widget? closedSuffixIcon;

  /// Suffix icon for opened/expanded state of [CustomDropdown].
  final Widget? expandedSuffixIcon;

  /// Called when the item of the [CustomDropdown] should change.
  final Function(T)? onChanged;

  /// Hide the selected item from the [items] list.
  final bool excludeSelected;

  /// [CustomDropdown] field color (closed state).
  final Color? closedFillColor;

  /// [CustomDropdown] overlay color (opened/expanded state).
  final Color? expandedFillColor;

  /// Can close [CustomDropdown] overlay by tapping outside.
  /// Here "outside" covers the entire screen.
  final bool canCloseOutsideBounds;

  /// Hide the selected item field when [CustomDropdown] overlay opened/expanded.
  final bool hideSelectedFieldWhenExpanded;

  /// The asynchronous computation from which the items list returns.
  final ValueChanged<String> futureRequest;
  final ValueChanged<String> futureRequestPaginate;

  /// Text that notify there's no search results match.
  final String? noResultFoundText;

  /// Duration after which the [futureRequest] is to be executed.
  final Duration? futureRequestDelay;

  /// Text maxlines for header and list item text.
  /// Useless if any or both [headerBuilder] and [listItemBuilder] provided.
  final int maxlines;

  /// The [listItemBuilder] that will be used to build item on demand.
  // ignore: library_private_types_in_public_api
  final _ListItemBuilder<T>? listItemBuilder;

  /// The [headerBuilder] that will be used to build [CustomDropdown] header field.
  // ignore: library_private_types_in_public_api
  final _HeaderBuilder<T>? headerBuilder;

  /// The [hintBuilder] that will be used to build [CustomDropdown] hint of header field.
  // ignore: library_private_types_in_public_api
  final _HintBuilder? hintBuilder;

  /// The [noResultFoundBuilder] that will be used to build area when there's no search results match.
  // ignore: library_private_types_in_public_api
  final _NoResultFoundBuilder? noResultFoundBuilder;

  final bool isLoading;

  final bool isFailed;
  final bool isEndPage;
  final bool hideSearch;

  final ValueNotifier<T?>? selectedItemNotifier;

  final bool isAutoUpdate;

  const CustomDropdown({
    super.key,
    this.isAutoUpdate = true,
    this.selectedItemNotifier,
    required this.items,
    required this.futureRequest,
    required this.futureRequestPaginate,
    this.initialItem,
    this.hintText,
    this.searchHintText,
    this.noResultFoundText,
    this.errorStyle,
    this.closedErrorBorder,
    this.closedErrorBorderRadius,
    this.validator,
    this.validateOnChange = true,
    this.closedBorder,
    this.closedBorderRadius,
    this.expandedBorder,
    this.expandedBorderRadius,
    this.closedSuffixIcon,
    this.expandedSuffixIcon,
    this.multiItemsNotifier,
    this.multiSelect = false,
    this.isEndPage = false,
    this.listItemBuilder,
    this.headerBuilder,
    this.hintBuilder,
    this.onChanged,
    this.maxlines = 1,
    this.canCloseOutsideBounds = true,
    this.hideSelectedFieldWhenExpanded = false,
    this.excludeSelected = true,
    this.closedFillColor,
    this.expandedFillColor,
    this.isLoading = false,
    this.hideSearch = false,
    this.isFailed = false,
  }) : futureRequestDelay = null,
       noResultFoundBuilder = null;

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  final layerLink = LayerLink();
  late ValueNotifier<T?> selectedItemNotifier;

  @override
  void initState() {
    super.initState();
    selectedItemNotifier = widget.selectedItemNotifier ?? ValueNotifier(widget.initialItem);
  }

  @override
  void dispose() {
    // selectedItemNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeHintText = widget.hintText ?? _defaultHintValue;

    return FormField<T>(
      initialValue: selectedItemNotifier.value,

      validator: (val) {
        if (widget.validator != null) {
          return widget.validator!(val);
        }
        return null;
      },
      builder: (FormFieldState<T> formFieldState) {
        return InputDecorator(
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            filled: true,
            fillColor: context.theme.colorScheme.surface,
            focusColor: context.theme.primaryColor,
            hoverColor: Colors.white,
            labelStyle: context.textTheme.titleLarge,
            hintStyle: context.textTheme.titleLarge,
            error: !formFieldState.validate()
                ? Text(
                    formFieldState.errorText!,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: context.theme.colorScheme.error,
                    ),
                  )
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.theme.hintColor.withOpacity(0.2)),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.theme.primaryColor),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.theme.hintColor.withOpacity(0.2)),
            ),
          ),
          child: _OverlayBuilder(
            overlay: (size, hideCallback) {
              return _DropdownOverlay<T>(
                futureRequestPaginate: widget.futureRequestPaginate,
                isEndPage: widget.isEndPage,
                isFailed: widget.isFailed,
                isLoading: widget.isLoading,
                onItemSelect: (T value) {
                  if (widget.multiSelect) {
                    if (widget.multiItemsNotifier!.value.contains(value)) {
                      widget.multiItemsNotifier?.value = List.of(
                        widget.multiItemsNotifier?.value ?? [],
                      )..remove(value);
                    } else {
                      widget.multiItemsNotifier?.value = List.of(
                        widget.multiItemsNotifier?.value ?? [],
                      )..add(value);
                    }
                  } else if (widget.isAutoUpdate) {
                    selectedItemNotifier.value = value;
                  }

                  if (widget.onChanged != null) {
                    widget.onChanged!(value);
                  }

                  formFieldState.didChange(value);

                  if (widget.validateOnChange) {
                    formFieldState.validate();
                  }
                },
                noResultFoundText: widget.noResultFoundText ?? 'No result found.',
                noResultFoundBuilder: widget.noResultFoundBuilder,
                items: widget.items,
                selectedItemNotifier: selectedItemNotifier,
                size: size,
                listItemBuilder: widget.listItemBuilder,
                layerLink: layerLink,
                hideOverlay: hideCallback,
                headerBuilder: widget.headerBuilder,
                hintText: safeHintText,
                searchHintText: widget.searchHintText ?? 'Search',
                hintBuilder: widget.hintBuilder,
                excludeSelected: widget.excludeSelected,
                canCloseOutsideBounds: widget.canCloseOutsideBounds,
                border: widget.expandedBorder,
                borderRadius: widget.expandedBorderRadius,
                futureRequest: widget.futureRequest,
                futureRequestDelay: widget.futureRequestDelay,
                hideSelectedFieldWhenOpen: widget.hideSelectedFieldWhenExpanded,
                hideSearch: widget.hideSearch,
                fillColor: widget.expandedFillColor,
                suffixIcon: widget.expandedSuffixIcon,
                maxlines: widget.maxlines,
              );
            },
            child: (showCallback) {
              return CompositedTransformTarget(
                link: layerLink,
                child: _DropDownField<T>(
                  onTap: showCallback,
                  selectedItemNotifier: selectedItemNotifier,
                  border: formFieldState.hasError
                      ? widget.closedErrorBorder ?? _defaultErrorBorder
                      : widget.closedBorder,
                  borderRadius: formFieldState.hasError
                      ? widget.closedErrorBorderRadius
                      : widget.closedBorderRadius,
                  hintText: safeHintText,
                  hintBuilder: widget.hintBuilder,
                  headerBuilder: widget.headerBuilder,
                  suffixIcon: widget.closedSuffixIcon,
                  fillColor: widget.closedFillColor,
                  maxlines: widget.maxlines,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
