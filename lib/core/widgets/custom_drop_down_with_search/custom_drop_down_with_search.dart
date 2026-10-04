import 'package:flutter/material.dart';

import '../../extensions/context_extensions.dart';
import 'animated_custom_dropdown/custom_dropdown.dart';

class CustomDropdownWithSearch<T> extends StatefulWidget {
  const CustomDropdownWithSearch({
    super.key,
    required this.getData,
    required this.getDataPaginate,
    required this.itemToString,
    required this.onChange,
    required this.hintText,
    required this.items,
    this.initialItem,
    required this.isLoading,
    required this.isEndPage,
    required this.isFailed,
    this.isInit = true,
    this.validator,
    this.selectedItemNotifier,
    this.multiItemsNotifier,
    this.isAutoUpdate = true,
    this.multiSelect = false,
    this.hideSelectedFieldWhenExpanded = false,
    this.hideSearch = false,
  });
  final ValueChanged<String> getData;
  final ValueChanged<String> getDataPaginate;
  final ValueChanged<T> onChange;
  final String Function(T item) itemToString;
  final T? initialItem;
  final String hintText;
  final List<T> items;
  final bool isLoading;
  final bool hideSelectedFieldWhenExpanded;
  final bool hideSearch;
  final bool isEndPage;
  final bool isFailed;
  final bool isInit;
  final String? Function(T? value)? validator;
  final ValueNotifier<T?>? selectedItemNotifier;
  final ValueNotifier<List<T>>? multiItemsNotifier;
  final bool multiSelect;
  final bool isAutoUpdate;
  const CustomDropdownWithSearch.multiSelect({
    super.key,
    required this.getData,
    required this.getDataPaginate,
    required this.itemToString,
    required this.onChange,
    required this.hintText,
    required this.items,
    this.initialItem,
    this.multiItemsNotifier,
    required this.isLoading,
    required this.isInit,
    required this.isEndPage,
    required this.isFailed,
    this.validator,
    this.selectedItemNotifier,
    this.isAutoUpdate = false,
    this.multiSelect = true,
    this.hideSearch = false,
    this.hideSelectedFieldWhenExpanded = false,
  }) : assert(multiItemsNotifier != null, 'Multi Item Notifier Shouldnt be null in multiselect');
  @override
  State<CustomDropdownWithSearch<T>> createState() => _CustomDropdownWithSearchState<T>();
}

class _CustomDropdownWithSearchState<T> extends State<CustomDropdownWithSearch<T>> {
  @override
  void initState() {
    super.initState();
    if (widget.isInit) {
      widget.getData('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: CustomDropdown<T>(
        futureRequestPaginate: widget.getDataPaginate,
        isEndPage: widget.isEndPage,
        futureRequest: widget.getData,
        validator: widget.validator,
        hideSelectedFieldWhenExpanded: widget.hideSelectedFieldWhenExpanded,
        items: widget.items,
        selectedItemNotifier: widget.selectedItemNotifier,
        isAutoUpdate: widget.isAutoUpdate,
        hintText: widget.hintText,
        hintBuilder: (context, hint) {
          return widget.multiSelect
              ? ValueListenableBuilder(
                  valueListenable: widget.multiItemsNotifier!,
                  builder: (context, values, _) {
                    return values.isNotEmpty
                        ? Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: values
                                .map(
                                  (e) => Chip(
                                    onDeleted: () {
                                      widget.multiItemsNotifier!.value = List.of(values)..remove(e);
                                    },
                                    color: WidgetStatePropertyAll(context.primaryColor),
                                    deleteIcon: Icon(
                                      Icons.close,
                                      color: context.theme.colorScheme.onPrimary,
                                    ),
                                    padding: EdgeInsets.zero,
                                    label: Text(
                                      widget.itemToString(e),
                                      style: context.textTheme.titleMedium?.copyWith(
                                        color: context.theme.hintColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          )
                        : Text(
                            hint,
                            style: context.textTheme.titleMedium?.copyWith(
                              color: context.theme.hintColor,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                  },
                )
              : Text(
                  hint,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.theme.hintColor,
                    fontWeight: FontWeight.bold,
                  ),
                );
        },
        listItemBuilder: (context, item) {
          return Text(widget.itemToString(item), style: context.textTheme.titleLarge);
        },
        headerBuilder: (context, selectedItem) {
          return Text(
            widget.itemToString(selectedItem),
            style: context.textTheme.titleMedium?.copyWith(
              color: context.theme.hintColor,
              fontWeight: FontWeight.bold,
            ),
          );
        },

        hideSearch: widget.hideSearch,
        multiItemsNotifier: widget.multiItemsNotifier,
        multiSelect: widget.multiSelect,
        onChanged: widget.onChange,
        initialItem: widget.initialItem,
        isLoading: widget.isLoading,
        isFailed: widget.isFailed,
      ),
    );
  }
}
