import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../domain/repositories/post_repository.dart';
import '../../../domain/repositories/step_type_repository.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/step_type_model.dart';
import '../../../data/models/targeting_model.dart';
import '../../bloc/auth/auth_bloc.dart';

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
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: widget.enabled ? widget.onRemove : null,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              enabled: widget.enabled,
              decoration: const InputDecoration(
                labelText: 'Step Title',
                border: OutlineInputBorder(),
                hintText: 'e.g., Mix the ingredients',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a step title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              enabled: widget.enabled,
              decoration: const InputDecoration(
                labelText: 'Step Description',
                border: OutlineInputBorder(),
                hintText: 'Brief description of this step',
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<PostStepWidget> _steps = [];
  String _title = '';
  String _description = '';
  final _postRepository = getIt<PostRepository>();
  final _stepTypeRepository = getIt<StepTypeRepository>();
  bool _isLoading = false;
  List<StepTypeModel> _availableStepTypes = [];

  // Targeting fields
  final _interestsController = TextEditingController();
  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();
  final _locationsController = TextEditingController();
  final _languagesController = TextEditingController();
  String? _selectedExperienceLevel;
  final _skillsController = TextEditingController();
  final _industriesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStepTypes();
  }

  @override
  void dispose() {
    _interestsController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _locationsController.dispose();
    _languagesController.dispose();
    _skillsController.dispose();
    _industriesController.dispose();
    super.dispose();
  }

  Future<void> _loadStepTypes() async {
    try {
      final types = await _stepTypeRepository.getStepTypes();
      setState(() {
        _availableStepTypes = types;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load step types: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addStep() {
    setState(() {
      _steps.add(PostStepWidget(
        key: UniqueKey(),
        onRemove: () => _removeStep(_steps.length - 1),
        stepNumber: _steps.length + 1,
        enabled: !_isLoading,
        stepTypes: _availableStepTypes,
      ));
    });
  }

  void _removeStep(int index) {
    setState(() {
      _steps.removeAt(index);
      // Update step numbers
      for (var i = 0; i < _steps.length; i++) {
        _steps[i] = PostStepWidget(
          key: UniqueKey(),
          onRemove: () => _removeStep(i),
          stepNumber: i + 1,
          enabled: !_isLoading,
          stepTypes: _availableStepTypes,
        );
      }
    });
  }

  Future<void> _savePost() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authState = context.read<AuthBloc>().state;
        if (!authState.isAuthenticated || authState.userId == null) {
          throw Exception('User not authenticated');
        }

        final steps = _steps
            .map((stepWidget) => stepWidget.toPostStep())
            .where((step) => step != null)
            .cast<PostStep>()
            .toList();

        if (steps.isEmpty) {
          throw Exception('Please add at least one step');
        }

        final post = PostModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: authState.userId!,
          username: authState.username ?? 'Anonymous',
          userProfileImage: 'https://i.pravatar.cc/150?u=${authState.userId}',
          title: _title,
          description: _description,
          steps: steps,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          likes: [],
          comments: [],
          status: PostStatus.active,
          targetingCriteria: _buildTargetingCriteria(),
          aiMetadata: {
            'tags': ['tutorial', 'multi-step'],
            'category': 'tutorial',
          },
          ratings: [],
          userTraits: [],
        );

        await _postRepository.createPost(post);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post created successfully')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create post: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  TargetingCriteria? _buildTargetingCriteria() {
    final interests = _parseCommaSeparatedList(_interestsController.text);
    final locations = _parseCommaSeparatedList(_locationsController.text);
    final languages = _parseCommaSeparatedList(_languagesController.text);
    final skills = _parseCommaSeparatedList(_skillsController.text);
    final industries = _parseCommaSeparatedList(_industriesController.text);
    final minAge = _parseIntOrNull(_minAgeController.text);
    final maxAge = _parseIntOrNull(_maxAgeController.text);

    if (interests == null &&
        locations == null &&
        languages == null &&
        skills == null &&
        industries == null &&
        minAge == null &&
        maxAge == null &&
        _selectedExperienceLevel == null) {
      return null;
    }

    return TargetingCriteria(
      interests: interests,
      minAge: minAge,
      maxAge: maxAge,
      locations: locations,
      languages: languages,
      experienceLevel: _selectedExperienceLevel,
      skills: skills,
      industries: industries,
    );
  }

  List<String>? _parseCommaSeparatedList(String value) {
    if (value.isEmpty) return null;
    return value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  int? _parseIntOrNull(String value) {
    if (value.isEmpty) return null;
    return int.tryParse(value);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isLoading) return false;
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Post'),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : _savePost,
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Post'),
            ),
          ],
        ),
        body: Stack(
          children: [
            Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    enabled: !_isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., How to Make Perfect Pancakes',
                    ),
                    onChanged: (value) => _title = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    enabled: !_isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      hintText: 'A brief description of what this post is about',
                    ),
                    maxLines: 3,
                    onChanged: (value) => _description = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ..._steps,
                  if (_availableStepTypes.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _addStep,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Step'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black12,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
