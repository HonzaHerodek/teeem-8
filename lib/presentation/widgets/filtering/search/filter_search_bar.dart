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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: widget.filterType.searchPlaceholder,
                hintStyle: const TextStyle(color: Colors.white70),
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search, color: Colors.white),
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
          ),
        ],
      ),
    );
  }
}
