import 'package:flutter/material.dart';
import '../../data/models/targeting_model.dart';

class TargetingFilterDialog extends StatefulWidget {
  final TargetingCriteria? initialCriteria;
  final Function(TargetingCriteria?) onApply;

  const TargetingFilterDialog({
    super.key,
    this.initialCriteria,
    required this.onApply,
  });

  @override
  State<TargetingFilterDialog> createState() => _TargetingFilterDialogState();
}

class _TargetingFilterDialogState extends State<TargetingFilterDialog> {
  late TextEditingController _interestsController;
  late TextEditingController _locationsController;
  late TextEditingController _languagesController;
  late TextEditingController _skillsController;
  late TextEditingController _industriesController;
  String? _experienceLevel;
  int? _minAge;
  int? _maxAge;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final criteria = widget.initialCriteria;
    _interestsController = TextEditingController(
      text: criteria?.interests?.join(', '),
    );
    _locationsController = TextEditingController(
      text: criteria?.locations?.join(', '),
    );
    _languagesController = TextEditingController(
      text: criteria?.languages?.join(', '),
    );
    _skillsController = TextEditingController(
      text: criteria?.skills?.join(', '),
    );
    _industriesController = TextEditingController(
      text: criteria?.industries?.join(', '),
    );
    _experienceLevel = criteria?.experienceLevel;
    _minAge = criteria?.minAge;
    _maxAge = criteria?.maxAge;
  }

  List<String>? _splitTextToList(String text) {
    if (text.trim().isEmpty) return null;
    return text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  void _applyFilter() {
    final criteria = TargetingCriteria(
      interests: _splitTextToList(_interestsController.text),
      locations: _splitTextToList(_locationsController.text),
      languages: _splitTextToList(_languagesController.text),
      skills: _splitTextToList(_skillsController.text),
      industries: _splitTextToList(_industriesController.text),
      experienceLevel: _experienceLevel,
      minAge: _minAge,
      maxAge: _maxAge,
    );
    widget.onApply(criteria);
    Navigator.of(context).pop();
  }

  void _clearFilter() {
    widget.onApply(null);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Feed',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _interestsController,
              decoration: const InputDecoration(
                labelText: 'Interests',
                hintText: 'Enter interests separated by commas',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Min Age',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _minAge = int.tryParse(value);
                      });
                    },
                    controller: TextEditingController(
                      text: _minAge?.toString() ?? '',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Max Age',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _maxAge = int.tryParse(value);
                      });
                    },
                    controller: TextEditingController(
                      text: _maxAge?.toString() ?? '',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _experienceLevel,
              decoration: const InputDecoration(
                labelText: 'Experience Level',
              ),
              items: const [
                DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                DropdownMenuItem(
                    value: 'intermediate', child: Text('Intermediate')),
                DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
              ],
              onChanged: (value) {
                setState(() {
                  _experienceLevel = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationsController,
              decoration: const InputDecoration(
                labelText: 'Locations',
                hintText: 'Enter locations separated by commas',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _languagesController,
              decoration: const InputDecoration(
                labelText: 'Languages',
                hintText: 'Enter languages separated by commas',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _skillsController,
              decoration: const InputDecoration(
                labelText: 'Skills',
                hintText: 'Enter skills separated by commas',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _industriesController,
              decoration: const InputDecoration(
                labelText: 'Industries',
                hintText: 'Enter industries separated by commas',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _clearFilter,
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _applyFilter,
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _interestsController.dispose();
    _locationsController.dispose();
    _languagesController.dispose();
    _skillsController.dispose();
    _industriesController.dispose();
    super.dispose();
  }
}
