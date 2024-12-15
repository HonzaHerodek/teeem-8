import 'package:flutter/material.dart';
import '../../core/services/trait_service.dart';
import '../../data/models/trait_model.dart';

class AddTraitDialog extends StatefulWidget {
  final Function(TraitModel) onTraitAdded;

  const AddTraitDialog({
    Key? key,
    required this.onTraitAdded,
  }) : super(key: key);

  @override
  State<AddTraitDialog> createState() => _AddTraitDialogState();
}

class _AddTraitDialogState extends State<AddTraitDialog> {
  String? _selectedCategory;
  TraitModel? _selectedTrait;
  final TextEditingController _valueController = TextEditingController();
  List<TraitModel> _availableTraits = [];

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  void _updateAvailableTraits() {
    if (_selectedCategory != null) {
      setState(() {
        _availableTraits = TraitService.getTraitsForCategory(_selectedCategory!);
        _selectedTrait = null;
        _valueController.clear();
      });
      debugPrint('Available traits for $_selectedCategory: $_availableTraits'); // Debug log
    }
  }

  String _generateUniqueId() {
    return '${_selectedCategory}_${DateTime.now().millisecondsSinceEpoch}';
  }

  void _handleTraitAdded() {
    if (_selectedCategory != null &&
        _selectedTrait != null &&
        _valueController.text.isNotEmpty) {
      debugPrint('Creating new trait...'); // Debug log
      // Create a new trait with a unique ID
      final newTrait = TraitModel(
        id: _generateUniqueId(), // Generate a unique ID
        name: _selectedTrait!.name,
        iconData: _selectedTrait!.iconData,
        value: _valueController.text,
        category: _selectedCategory!,
        displayOrder: _selectedTrait!.displayOrder,
      );
      debugPrint('New trait created: $newTrait'); // Debug log
      
      // Ensure the callback is called
      try {
        widget.onTraitAdded(newTrait);
        debugPrint('Trait added callback executed successfully'); // Debug log
      } catch (e) {
        debugPrint('Error in trait added callback: $e'); // Error log
      }
      
      Navigator.pop(context);
    } else {
      debugPrint('Cannot add trait: missing category, trait, or value'); // Debug log
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = TraitService.getAvailableCategories();
    debugPrint('Available categories: $categories'); // Debug log

    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Trait',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              dropdownColor: Colors.grey[850],
              style: const TextStyle(color: Colors.white),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(
                    category.toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                debugPrint('Category selected: $value'); // Debug log
                setState(() {
                  _selectedCategory = value;
                });
                _updateAvailableTraits();
              },
            ),
            const SizedBox(height: 16),
            if (_selectedCategory != null) ...[
              DropdownButtonFormField<TraitModel>(
                value: _selectedTrait,
                decoration: const InputDecoration(
                  labelText: 'Trait',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                dropdownColor: Colors.grey[850],
                style: const TextStyle(color: Colors.white),
                items: _availableTraits.map((trait) {
                  return DropdownMenuItem(
                    value: trait,
                    child: Text(
                      trait.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  debugPrint('Trait selected: $value'); // Debug log
                  setState(() {
                    _selectedTrait = value;
                    if (value != null) {
                      _valueController.text = value.value;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _valueController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Value',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                onChanged: (value) {
                  debugPrint('Value changed: $value'); // Debug log
                  setState(() {}); // Trigger rebuild to update Add button state
                },
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _selectedCategory != null &&
                          _selectedTrait != null &&
                          _valueController.text.isNotEmpty
                      ? _handleTraitAdded
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
