import 'package:flutter/material.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/step_type_model.dart';

class PostStepWidget extends StatefulWidget {
  final VoidCallback onRemove;
  final int stepNumber;
  final bool enabled;
  final List<StepTypeModel> stepTypes;

  const PostStepWidget({
    super.key,
    required this.onRemove,
    required this.stepNumber,
    required this.stepTypes,
    this.enabled = true,
  });

  PostStep? toPostStep() {
    if (_PostStepWidgetState.currentState == null) return null;
    return _PostStepWidgetState.currentState!.getStepData();
  }

  @override
  State<PostStepWidget> createState() => _PostStepWidgetState();
}

class _PostStepWidgetState extends State<PostStepWidget> {
  static _PostStepWidgetState? currentState;
  late StepTypeModel _selectedStepType;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final Map<String, TextEditingController> _optionControllers = {};

  @override
  void initState() {
    super.initState();
    currentState = this;
    _selectedStepType = widget.stepTypes.first;
    _initializeOptionControllers();
  }

  void _initializeOptionControllers() {
    for (final option in _selectedStepType.options) {
      _optionControllers[option.id] = TextEditingController();
    }
  }

  @override
  void dispose() {
    if (currentState == this) {
      currentState = null;
    }
    _titleController.dispose();
    _descriptionController.dispose();
    for (final controller in _optionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  PostStep getStepData() {
    final content = <String, dynamic>{};
    for (final option in _selectedStepType.options) {
      content[option.id] = _optionControllers[option.id]?.text ?? '';
    }

    return PostStep(
      id: 'step_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text,
      description: _descriptionController.text,
      type: StepType.values.firstWhere(
        (t) => t.name == _selectedStepType.id,
        orElse: () => StepType.text,
      ),
      content: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white.withOpacity(0.15),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step ${widget.stepNumber}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                  onPressed: widget.enabled ? widget.onRemove : null,
                  color: Colors.red,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              enabled: widget.enabled,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Step Title',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                hintText: 'e.g., Mix the ingredients',
                hintStyle: TextStyle(color: Colors.white30),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a step title';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              enabled: widget.enabled,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Step Description',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                hintText: 'Brief description of this step',
                hintStyle: TextStyle(color: Colors.white30),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
