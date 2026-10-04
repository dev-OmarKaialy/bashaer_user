part of '../custom_dropdown.dart';

class _SearchField<T> extends StatefulWidget {
  final List<T> items;
  // final ValueChanged<List<T>> onSearchedItems;
  final String searchHintText;
  final ValueChanged<String> futureRequest;
  final Duration? futureRequestDelay;
  final TextEditingController searchCtrl;

  const _SearchField({
    super.key,
    required this.items,
    // required this.onSearchedItems,
    required this.searchHintText,
    required this.futureRequest,
    required this.futureRequestDelay,
    required this.searchCtrl,
  });

  @override
  State<_SearchField<T>> createState() => _SearchFieldState<T>();
}

class _SearchFieldState<T> extends State<_SearchField<T>> {
  bool isFieldEmpty = false;
  FocusNode focusNode = FocusNode();
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    if (widget.items.isEmpty) {
      focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    widget.searchCtrl.dispose();
    _delayTimer?.cancel();
    super.dispose();
  }

  void onClear() {
    {
      widget.searchCtrl.clear();
      widget.futureRequest("");
      // widget.onSearchedItems(widget.items);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        focusNode: focusNode,
        onChanged: (val) async {
          if (val.isEmpty) {
            isFieldEmpty = true;
          } else if (isFieldEmpty) {
            isFieldEmpty = false;
          }

          if (val.isNotEmpty) {
            if (widget.futureRequestDelay != null) {
              _delayTimer?.cancel();
              _delayTimer = Timer(widget.futureRequestDelay ?? Duration.zero, () {
                widget.futureRequest(val);
              });
            } else {
              widget.futureRequest(val);
            }
          } else {
            widget.futureRequest("");
          }
        },
        controller: widget.searchCtrl,
        decoration: InputDecoration(
          filled: true,
          // fillColor: Colors.grey[50],
          constraints: const BoxConstraints.tightFor(height: 40),
          contentPadding: const EdgeInsets.all(8),
          hintText: widget.searchHintText,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
          suffixIcon: GestureDetector(
            onTap: onClear,
            child: ListenableBuilder(
              listenable: widget.searchCtrl,
              builder: (context, c) {
                return Icon(
                  widget.searchCtrl.text.isEmpty ? Icons.refresh : Icons.close,
                  color: Colors.grey,
                  size: 20,
                );
              },
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.withOpacity(.25), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.withOpacity(.25), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.withOpacity(.25), width: 1),
          ),
        ),
      ),
    );
  }
}
