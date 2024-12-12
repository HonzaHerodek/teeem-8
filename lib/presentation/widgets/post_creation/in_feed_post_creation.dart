import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../domain/repositories/post_repository.dart';
import '../../../domain/repositories/step_type_repository.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/step_type_model.dart';
import '../../bloc/auth/auth_bloc.dart';
import './post_step_widget.dart';

class InFeedPostCreation extends StatefulWidget {
  final VoidCallback onCancel;
  final Function(bool success) onComplete;

  const InFeedPostCreation({
    super.key,
    required this.onCancel,
    required this.onComplete,
  });

  @override
  InFeedPostCreationState createState() => InFeedPostCreationState();
}

class InFeedPostCreationState extends State<InFeedPostCreation> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<Widget> _steps = [];
  final _postRepository = getIt<PostRepository>();
  final _stepTypeRepository = getIt<StepTypeRepository>();
  bool _isLoading = false;
  List<StepTypeModel> _availableStepTypes = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadStepTypes();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
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
    
    // Scroll to the bottom after adding a step
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _removeStep(int index) {
    setState(() {
      _steps.removeAt(index);
      // Update step numbers
      for (var i = 0; i < _steps.length; i++) {
        final currentStep = _steps[i];
        if (currentStep is PostStepWidget) {
          _steps[i] = PostStepWidget(
            key: UniqueKey(),
            onRemove: () => _removeStep(i),
            stepNumber: i + 1,
            enabled: !_isLoading,
            stepTypes: _availableStepTypes,
          );
        }
      }
    });
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authState = context.read<AuthBloc>().state;
      if (!authState.isAuthenticated || authState.userId == null) {
        throw Exception('User not authenticated');
      }

      final steps = _steps
          .whereType<PostStepWidget>()
          .map((stepWidget) => stepWidget.toPostStep())
          .where((step) => step != null)
          .cast<PostStep>()
          .toList();

      if (steps.isEmpty) {
        throw Exception('Please add at least one step');
      }

      // TODO: Debug posts with only one step - they show multiple false carousel dots/miniatures
      final post = PostModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: authState.userId!,
        username: authState.username ?? 'Anonymous',
        userProfileImage: 'https://i.pravatar.cc/150?u=${authState.userId}',
        title: _titleController.text,
        description: _descriptionController.text,
        steps: steps,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        likes: [],
        comments: [],
        status: PostStatus.active,
        targetingCriteria: null,
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
        widget.onComplete(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create post: $e'),
            backgroundColor: Colors.red,
          ),
        );
        widget.onComplete(false);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width - 32;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.15),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 35,
            spreadRadius: 8,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 25,
            spreadRadius: 5,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          color: Colors.white.withOpacity(0.1),
          child: Form(
            key: _formKey,
            child: Center(
              child: SizedBox(
                width: size * 0.8,
                height: size * 0.8,
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Create New Post',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      enabled: !_isLoading,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        hintText: 'e.g., How to Make Perfect Pancakes',
                        hintStyle: TextStyle(color: Colors.white30),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      enabled: !_isLoading,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        hintText: 'A brief description of what this post is about',
                        hintStyle: TextStyle(color: Colors.white30),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ..._steps,
                    if (_availableStepTypes.isNotEmpty)
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _addStep,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Step'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          backgroundColor: Colors.white24,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
