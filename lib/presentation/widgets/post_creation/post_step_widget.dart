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

class PostStepWidgetState extends State<PostStepWidget>
    with AutomaticKeepAliveClientMixin {
  StepTypeModel? _selectedStepType;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final Map<String, TextEditingController> _optionControllers = {};

  @override
  bool get wantKeepAlive => true;

  // Add this getter to expose step type selection state
  bool get hasSelectedStepType => _selectedStepType != null;

  // Public getter for _selectedStepType
  StepTypeModel? getSelectedStepType() {
    return _selectedStepType;
  }

  @override
  void initState() {
    super.initState();
    // Restore state if available
    if (_selectedStepType != null) {
      _initializeOptionControllers();
      _restoreOptionValues();
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

  void _initializeOptionControllers() {
    if (_selectedStepType == null) return;
    for (final option in _selectedStepType!.options) {
      _optionControllers[option.id] = TextEditingController();
    }
  }

  void _restoreOptionValues() {
    if (_selectedStepType == null) return;
    for (final option in _selectedStepType!.options) {
      if (_optionControllers.containsKey(option.id)) {
        // Restore value if available
        // _optionControllers[option.id]!.text = _optionValues[option.id] ?? '';
      }
    }
  }

  void _onStepTypeSelected(StepTypeModel type) {
    setState(() {
      _selectedStepType = type;
      // Clear and reinitialize option controllers
      for (final controller in _optionControllers.values) {
        controller.dispose();
      }
      _optionControllers.clear();
      _initializeOptionControllers();
      _restoreOptionValues();
      updateKeepAlive();
    });
  }

  bool validate() {
    return _formKey.currentState?.validate() ?? false;
  }

  PostStep getStepData() {
    if (_selectedStepType == null) {
      throw Exception('Step type not selected');
    }

    final content = <String, dynamic>{};
    for (final option in _selectedStepType!.options) {
      content[option.id] = _optionControllers[option.id]?.text ?? '';
    }

    return PostStep(
      id: 'step_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text,
      description: _descriptionController.text,
      type: StepType.values.firstWhere(
        (t) => t.name == _selectedStepType!.id,
        orElse: () => StepType.text,
      ),
      content: content,
    );
  }

  IconData _getIconData(String iconString) {
    if (iconString.isEmpty) {
      return Icons.article;
    }

    try {
      switch (iconString.toLowerCase()) {
        case 'text':
          return Icons.text_fields;
        case 'image':
          return Icons.image;
        case 'video':
          return Icons.videocam;
        case 'audio':
          return Icons.audiotrack;
        case 'quiz':
          return Icons.quiz;
        case 'code':
          return Icons.code;
        case 'ar':
          return Icons.view_in_ar;
        case 'vr':
          return Icons.vrpano;
        case 'document':
          return Icons.description;
        case 'link':
          return Icons.link;
        default:
          return Icons.article;
      }
    } catch (e) {
      return Icons.article;
    }
  }

  Widget _buildStepTypeMiniature(StepTypeModel type) {
    // Parse color with a fallback
    Color backgroundColor;
    try {
      backgroundColor = Color(int.parse(type.color.replaceAll('#', '0xFF')));
    } catch (e) {
      backgroundColor = Colors.grey;
    }

    return GestureDetector(
      onTap: widget.enabled ? () => _onStepTypeSelected(type) : null,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconData(type.icon),
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                type.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            onChanged: (value) {
              updateKeepAlive();
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
            onChanged: (value) {
              updateKeepAlive();
            },
          ),
          ..._selectedStepType!.options.map((option) => Padding(
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
                  onChanged: (value) {
                    updateKeepAlive();
                  },
                ),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: _selectedStepType == null
          ? Column(
              children: [
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: widget.stepTypes
                      .map((type) => _buildStepTypeMiniature(type))
                      .toList(),
                ),
              ],
            )
          : _buildStepForm(),
    );
  }
}
