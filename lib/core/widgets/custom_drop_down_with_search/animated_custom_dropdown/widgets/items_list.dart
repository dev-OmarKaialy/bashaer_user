part of '../custom_dropdown.dart';

class _ItemsList<T> extends StatelessWidget {
  final ScrollController scrollController;
  final T? selectedItem;
  final List<T> items;
  final Function(T) onItemSelect;
  final bool excludeSelected;
  final int itemsCount;
  final EdgeInsets padding;
  final _ListItemBuilder<T> listItemBuilder;

  const _ItemsList({
    super.key,
    required this.scrollController,
    required this.selectedItem,
    required this.items,
    this.itemsCount = 0,
    required this.onItemSelect,
    required this.excludeSelected,
    required this.padding,
    required this.listItemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: scrollController,
      child: ListView.builder(
        controller: scrollController,
        shrinkWrap: true,
        padding: padding,
        itemCount: items.length + itemsCount,
        itemBuilder: (_, index) {
          if (index >= items.length) {
            return const Center(child: CustomLoadingWidget());
          }
          final selected = !excludeSelected && selectedItem == items[index];

          return Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.grey[200],
              onTap: () => onItemSelect(items[index]),
              child: Container(
                color: selected ? Colors.grey[100] : Colors.transparent,
                padding: _listItemPadding,
                child: listItemBuilder(context, items[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}
