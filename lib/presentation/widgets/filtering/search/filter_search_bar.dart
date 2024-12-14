import 'package:flutter/material.dart';
import '../models/filter_type.dart';

class FilterSearchBar extends StatefulWidget {
  final FilterType filterType;
  final ValueChanged<String> onSearch;
  final VoidCallback onClose;

  const FilterSearchBar({
    super.key,
    required this.filterType,
    required this.onSearch,
    required this.onClose,
  });

  @override
  State<FilterSearchBar> createState() => _FilterSearchBarState();
}

class _FilterSearchBarState extends State<FilterSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true, // Automatically focus when shown
              decoration: InputDecoration(
                hintText: widget.filterType.searchPlaceholder,
                hintStyle: const TextStyle(color: Colors.white70),
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              ),
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              onChanged: widget.onSearch,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              _controller.clear();
              widget.onClose();
            },
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}
