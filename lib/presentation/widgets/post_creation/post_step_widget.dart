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
    if (key is GlobalKey<PostStepWidgetState>) {
      final state = (key as GlobalKey<PostStepWidgetState>).currentState;
      if (state != null) {
        return state.getStepData();
      }
    }
    return null;
  }

  @override
  State<PostStepWidget> createState() => PostStepWidgetState();
}

class PostStepWidgetState extends State<PostStepWidget> {
  late StepTypeModel _selectedStepType;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final Map<String, TextEditingController> _optionControllers = {};

  @override
  void initState() {
    super.initState();
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
    _titleController.dispose();
    _descriptionController.dispose();
    for (final controller in _optionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onStepTypeChanged(StepTypeModel? newType) {
    if (newType != null && newType != _selectedStepType) {
      setState(() {
        _selectedStepType = newType;
        // Clear and reinitialize option controllers
        for (final controller in _optionControllers.values) {
          controller.dispose();
        }
        _optionControllers.clear();
        _initializeOptionControllers();
      });
    }
  }

  bool validate() {
    return _formKey.currentState?.validate() ?? false;
  }

  PostStep getStepData() {
    print('Getting step data for step ${widget.stepNumber}'); // Debug print
    final content = <String, dynamic>{};
    for (final option in _selectedStepType.options) {
      content[option.id] = _optionControllers[option.id]?.text ?? '';
    }

    final step = PostStep(
      id: 'step_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text,
      description: _descriptionController.text,
      type: StepType.values.firstWhere(
        (t) => t.name == _selectedStepType.id,
        orElse: () => StepType.text,
      ),
      content: content,
    );
    print('Step data: $step'); // Debug print
    return step;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white.withOpacity(0.15),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
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
              DropdownButtonFormField<StepTypeModel>(
                value: _selectedStepType,
                items: widget.stepTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(
                            type.name,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ))
                    .toList(),
                onChanged: widget.enabled ? _onStepTypeChanged : null,
                decoration: const InputDecoration(
                  labelText: 'Step Type',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a step type';
                  }
                  return null;
                },
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a step description';
                  }
                  return null;
                },
              ),
              ..._selectedStepType.options.map((option) => Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextFormField(
                      controller: _optionControllers[option.id],
                      enabled: widget.enabled,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: option.label,
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: const OutlineInputBorder(),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white30),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        hintStyle: const TextStyle(color: Colors.white30),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please fill in this field';
                        }
                        return null;
                      },
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
