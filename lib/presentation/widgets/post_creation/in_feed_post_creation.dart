import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../domain/repositories/post_repository.dart';
import '../../../domain/repositories/step_type_repository.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/step_type_model.dart';
import '../../bloc/auth/auth_bloc.dart';
import './post_step_widget.dart';

// TODO: the confirmation action button in feed must be able to work with in_feed_post_creation and create a post like is the case with create_post_screen. Potential issues may be with handling context (steps, step types, step content) and with communication between the in_feed_post_creation and the feed_screen (i.e. the confirmation action button - in the area of a plus button (add post) after the plus button is clicked)

abstract class InFeedPostCreationController {
  Future<void> save();
}

class InFeedPostCreation extends StatefulWidget {
  final VoidCallback onCancel;
  final Function(bool success) onComplete;

  const InFeedPostCreation({
    super.key,
    required this.onCancel,
    required this.onComplete,
  });

  static InFeedPostCreationController? of(BuildContext context) {
    final state = context.findRootAncestorStateOfType<InFeedPostCreationState>();
    if (state != null) {
      return state;
    }
    return null;
  }

  @override
  State<InFeedPostCreation> createState() => InFeedPostCreationState();
}

class InFeedPostCreationState extends State<InFeedPostCreation>
    implements InFeedPostCreationController {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<GlobalKey<PostStepWidgetState>> _stepKeys = [];
  final List<PostStepWidget> _steps = [];
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
    final stepKey = GlobalKey<PostStepWidgetState>();
    final newStep = PostStepWidget(
      key: stepKey,
      onRemove: () => _removeStep(_steps.length - 1),
      stepNumber: _steps.length + 1,
      enabled: !_isLoading,
      stepTypes: _availableStepTypes,
    );

    setState(() {
      _stepKeys.add(stepKey);
      _steps.add(newStep);
    });

    // Scroll to the bottom after adding a step
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _removeStep(int index) {
    setState(() {
      _steps.removeAt(index);
      _stepKeys.removeAt(index);
      // Update step numbers
      for (var i = 0; i < _steps.length; i++) {
        final stepKey = GlobalKey<PostStepWidgetState>();
        _stepKeys[i] = stepKey;
        _steps[i] = PostStepWidget(
          key: stepKey,
          onRemove: () => _removeStep(i),
          stepNumber: i + 1,
          enabled: !_isLoading,
          stepTypes: _availableStepTypes,
        );
      }
    });
  }

  bool _validateSteps() {
    bool isValid = true;
    for (var i = 0; i < _stepKeys.length; i++) {
      final state = _stepKeys[i].currentState;
      if (state == null || !state.validate()) {
        isValid = false;
        print('Step ${i + 1} validation failed'); // Debug print
      }
    }
    return isValid;
  }

  @override
  Future<void> save() async {
    print('Attempting to save post...'); // Debug print

    if (_steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one step'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      print('Form validation failed'); // Debug print
      return;
    }

    if (!_validateSteps()) {
      print('Step validation failed'); // Debug print
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all step fields'),
          backgroundColor: Colors.red,
        ),
      );
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
          .map((stepWidget) {
            final step = stepWidget.toPostStep();
            print('Step data: $step'); // Debug print
            return step;
          })
          .where((step) => step != null)
          .cast<PostStep>()
          .toList();

      print('Creating post with ${steps.length} steps'); // Debug print

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
      print('Post created successfully'); // Debug print

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully')),
        );
        widget.onComplete(true);
      }
    } catch (e) {
      print('Error creating post: $e'); // Debug print
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

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    String? label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white24,
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white),
            onPressed: _isLoading ? null : onPressed,
            padding: const EdgeInsets.all(12),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
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
          child: Stack(
            children: [
              Form(
                key: _formKey,
                child: Center(
                  child: SizedBox(
                    width: size * 0.8,
                    height: size * 0.8,
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        const SizedBox(height: 40),
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
                            hintText: 'Title of Task',
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
                            hintText: 'short summary of the goal',
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
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(
                              icon: Icons.settings,
                              onPressed: () {
                                // TODO: Implement settings action
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.auto_awesome,
                              onPressed: () {
                                // TODO: Implement AI action
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.playlist_add,
                              onPressed: _addStep,
                              label: 'Add Step',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
              // Cancel button positioned at the top
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.225),
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: widget.onCancel,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
