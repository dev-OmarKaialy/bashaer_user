part of '../custom_dropdown.dart';

const _defaultOverlayIconUp = Icon(Icons.keyboard_arrow_up_rounded, color: Colors.black, size: 20);

const _headerPadding = EdgeInsets.all(16.0);
// const _overlayOuterPadding = EdgeInsets.only(bottom: 12, left: 12, right: 12);
const _overlayShadowOffset = Offset(0, 6);
const _listItemPadding = EdgeInsets.symmetric(vertical: 12, horizontal: 16);

class _DropdownOverlay<T> extends StatefulWidget {
  final List<T> items;
  final bool isLoading;
  final bool isEndPage;
  final bool isFailed;
  final ValueNotifier<T?> selectedItemNotifier;
  final Function(T) onItemSelect;
  final Size size;
  final LayerLink layerLink;
  final VoidCallback hideOverlay;
  final String hintText;
  final String searchHintText;
  final bool excludeSelected;
  final bool? hideSelectedFieldWhenOpen;
  final bool canCloseOutsideBounds;
  final ValueChanged<String> futureRequest;
  final ValueChanged<String> futureRequestPaginate;
  final Duration? futureRequestDelay;
  final Color? fillColor;
  final BoxBorder? border;
  final BorderRadius? borderRadius;
  final String noResultFoundText;
  final Widget? suffixIcon;
  final int maxlines;
  // ignore: library_private_types_in_public_api
  final _ListItemBuilder<T>? listItemBuilder;
  // ignore: library_private_types_in_public_api
  final _HeaderBuilder<T>? headerBuilder;
  // ignore: library_private_types_in_public_api
  final _HintBuilder? hintBuilder;
  // ignore: library_private_types_in_public_api
  final _NoResultFoundBuilder? noResultFoundBuilder;
  final ValueNotifier<List<T>>? multiItemsNotifier;
  final bool multiSelect;
  final bool hideSearch;

  const _DropdownOverlay({
    super.key,
    required this.items,
    required this.size,
    required this.layerLink,
    required this.hideOverlay,
    required this.hintText,
    required this.searchHintText,
    required this.selectedItemNotifier,
    required this.excludeSelected,
    required this.onItemSelect,
    required this.noResultFoundText,
    required this.canCloseOutsideBounds,
    required this.maxlines,
    this.suffixIcon,
    this.headerBuilder,
    this.multiItemsNotifier,
    this.multiSelect = false,
    this.isEndPage = false,
    this.hintBuilder,
    this.hideSelectedFieldWhenOpen = false,
    this.hideSearch = false,
    required this.futureRequest,
    required this.futureRequestPaginate,
    this.futureRequestDelay,
    this.listItemBuilder,
    this.noResultFoundBuilder,
    this.border,
    this.borderRadius,
    this.fillColor,
    this.isLoading = false,
    this.isFailed = false,
  });

  @override
  _DropdownOverlayState<T> createState() => _DropdownOverlayState<T>();
}

class _DropdownOverlayState<T> extends State<_DropdownOverlay<T>> {
  bool displayOverly = true;
  bool displayOverlayBottom = true;
  bool isSearchRequestLoading = false;
  bool? mayFoundSearchRequestResult;
  final searchCtrl = TextEditingController();

  late T? selectedItem;
  late List<T> _filteredItems; // To store the filtered items based on search query
  final key1 = GlobalKey(), key2 = GlobalKey();
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items; // Initially, no filtering, show all items
    // Update filtered items based on search query
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      adjustOverlayPosition(context);
    });
    searchCtrl.addListener(() {
      filterItems(searchCtrl.text);
    });

    selectedItem = widget.selectedItemNotifier.value;
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  // Function to filter items based on search text
  void filterItems(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredItems = widget.items;
      });
    } else {
      setState(() {
        _filteredItems = widget.items.where((item) {
          return item.toString().toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  Widget defaultHeaderBuilder(BuildContext context, T result) {
    return Text(
      result.toString(),
      maxLines: widget.maxlines,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    );
  }

  // default header builder
  Widget defaultHintBuilder(BuildContext context, String hint) {
    return Text(
      hint,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 16, color: Color(0xFFA7A7A7), fontWeight: FontWeight.w400),
    );
  }

  Widget defaultListItemBuilder(BuildContext context, T result) {
    return Text(
      result.toString(),
      maxLines: widget.maxlines,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget noResultFoundBuilder(BuildContext context, String text) {
    if (widget.noResultFoundBuilder != null) {
      return widget.noResultFoundBuilder!(context, text);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  // Function to determine if the overlay should open up or down
  void adjustOverlayPosition(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final dropdownHeight = 270.0; // Known height of the dropdown
    final dropdownPosition =
        (key1.currentContext?.findRenderObject() as RenderBox?)?.localToGlobal(Offset.zero).dy ??
        0.0;

    // Check if there is enough space below
    if (screenHeight - dropdownPosition < dropdownHeight) {
      setState(() {
        displayOverlayBottom = false; // Show overlay above
      });
    } else {
      setState(() {
        displayOverlayBottom = true; // Show overlay below
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final overlayOffset = Offset(-12, displayOverlayBottom ? 0 : 64);
    const listPadding = EdgeInsets.only(top: 8);
    final child = Stack(
      children: [
        Positioned(
          width: widget.size.width + 25,
          child: CompositedTransformFollower(
            link: widget.layerLink,
            followerAnchor: displayOverlayBottom ? Alignment.topLeft : Alignment.bottomLeft,
            showWhenUnlinked: false,
            offset: overlayOffset,
            child: Container(
              key: key1,
              padding: const EdgeInsets.only(top: 25),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: widget.fillColor ?? context.theme.scaffoldBackgroundColor,
                  border: widget.border,
                  borderRadius: widget.borderRadius ?? _defaultBorderRadius,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 24.0,
                      color: Colors.black.withOpacity(.08),
                      offset: _overlayShadowOffset,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: AnimatedSection(
                    onComplete: () {
                      adjustOverlayPosition(context);
                    },
                    animationDismissed: widget.hideOverlay,
                    expand: displayOverly,

                    axisAlignment: displayOverlayBottom ? 1.0 : -1.0,
                    child: SizedBox(
                      key: key2,
                      height: _filteredItems.length > 4 ? 270 : null,
                      child: ClipRRect(
                        borderRadius: widget.borderRadius ?? _defaultBorderRadius,
                        child: NotificationListener<OverscrollIndicatorNotification>(
                          onNotification: (notification) {
                            notification.disallowIndicator();
                            return true;
                          },
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              scrollbarTheme: ScrollbarThemeData(
                                thumbVisibility: WidgetStateProperty.all(true),
                                thickness: WidgetStateProperty.all(5),
                                radius: const Radius.circular(4),
                                thumbColor: WidgetStateProperty.all(Colors.grey[300]),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!widget.hideSelectedFieldWhenOpen!)
                                  Padding(
                                    padding: _headerPadding,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: selectedItem != null
                                              ? widget.headerBuilder != null
                                                    ? widget.headerBuilder!(
                                                        context,
                                                        selectedItem as T,
                                                      )
                                                    : defaultHeaderBuilder(
                                                        context,
                                                        selectedItem as T,
                                                      )
                                              : widget.multiSelect && widget.hintBuilder != null
                                              ? widget.hintBuilder!(context, widget.hintText)
                                              : defaultHintBuilder(context, widget.hintText),
                                        ),
                                        const SizedBox(width: 12),
                                        widget.suffixIcon ?? _defaultOverlayIconUp,
                                      ],
                                    ),
                                  ),
                                if (!widget.hideSearch)
                                  _SearchField<T>(
                                    items: widget.items,
                                    searchCtrl: searchCtrl,
                                    searchHintText: widget.searchHintText,
                                    futureRequest: (s) async {},
                                    futureRequestDelay: widget.futureRequestDelay,
                                  ),
                                if (widget.isFailed)
                                  Center(
                                    child: IconButton.filled(
                                      onPressed: () {
                                        widget.futureRequest.call(searchCtrl.text);
                                      },
                                      icon: const Icon(Icons.refresh),
                                    ),
                                  )
                                else if (widget.isLoading)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                                    child: Center(
                                      child: SizedBox(
                                        width: 25,
                                        height: 25,
                                        child: CircularProgressIndicator(
                                          color: context.primaryColor,
                                          strokeWidth: 3,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  _filteredItems.isNotEmpty
                                      ? Flexible(
                                          child: _ItemsList<T>(
                                            itemsCount: !widget.isEndPage ? 1 : 0,
                                            scrollController: scrollController,
                                            listItemBuilder:
                                                widget.listItemBuilder ?? defaultListItemBuilder,
                                            excludeSelected: widget.items.length > 1
                                                ? widget.excludeSelected
                                                : false,
                                            selectedItem: selectedItem,
                                            items: _filteredItems, // Show filtered items here
                                            padding: listPadding,
                                            onItemSelect: (T value) {
                                              widget.onItemSelect(value);
                                              if (!widget.multiSelect) {
                                                setState(() => displayOverly = false);
                                              }
                                            },
                                          ),
                                        )
                                      : noResultFoundBuilder(context, widget.noResultFoundText),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: () => setState(() => displayOverly = false),
      child: widget.canCloseOutsideBounds
          ? Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.transparent,
              child: child,
            )
          : child,
    );
  }
}
