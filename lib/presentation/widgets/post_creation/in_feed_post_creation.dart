import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../domain/repositories/post_repository.dart';
import '../../../domain/repositories/step_type_repository.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/step_type_model.dart';
import '../../bloc/auth/auth_bloc.dart';
import './post_step_widget.dart';

/// Controller for InFeedPostCreation widget.
abstract class InFeedPostCreationController {
  Future<void> save();
}

/// Widget for creating a post in the feed.
class InFeedPostCreation extends StatefulWidget {
  final VoidCallback onCancel;
  final Function(bool success) onComplete;

  const InFeedPostCreation({
    super.key,
    required this.onCancel,
    required this.onComplete,
  });

  static InFeedPostCreationController? of(BuildContext context) {
    final state =
        context.findRootAncestorStateOfType<InFeedPostCreationState>();
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
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadStepTypes();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pageController.dispose();
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

    // Navigate to the new step immediately
    _pageController.animateToPage(
      _steps.length, // Go to the newly added step
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _removeStep(int index) {
    // Only navigate back if we're removing the current step
    if (index == _currentPage - 1) {
      _pageController
          .previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      )
          .then((_) {
        if (mounted) {
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
      });
    } else {
      // Otherwise, remove immediately
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
  }

  void _handleCancelButtonPress() {
    if (_currentPage == 0) {
      // Cancel entire post creation
      widget.onCancel();
      return;
    }

    final stepState = _stepKeys[_currentPage - 1].currentState;
    if (stepState != null && stepState.hasSelectedStepType) {
      // Reset step type selection to allow choosing a different type
      setState(() {
        final stepKey = GlobalKey<PostStepWidgetState>();
        _stepKeys[_currentPage - 1] = stepKey;
        _steps[_currentPage - 1] = PostStepWidget(
          key: stepKey,
          onRemove: () => _removeStep(_currentPage - 1),
          stepNumber: _currentPage,
          enabled: !_isLoading,
          stepTypes: _availableStepTypes,
        );
      });
    } else {
      // Simply remove the step - _removeStep will handle the page transition
      _removeStep(_currentPage - 1);
    }
  }

  Widget _buildCancelButton() {
    return Positioned(
      top: -24, // Align center with top border
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white30, width: 1),
          ),
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _isLoading ? null : widget.onCancel,
            padding: const EdgeInsets.all(8),
          ),
        ),
      ),
    );
  }

  Widget _buildStepButton() {
    bool showEditIcon = _currentPage > 0 &&
        _steps.isNotEmpty &&
        _steps[_currentPage - 1].key is GlobalKey<PostStepWidgetState> &&
        (_steps[_currentPage - 1].key as GlobalKey<PostStepWidgetState>)
                .currentState !=
            null &&
        (_steps[_currentPage - 1].key as GlobalKey<PostStepWidgetState>)
            .currentState!
            .hasSelectedStepType;

    // Use the getter for _selectedStepType
    final currentStepState =
        (_steps[_currentPage - 1].key as GlobalKey<PostStepWidgetState>?)
            ?.currentState;
    final bool isStepTypeSelected =
        currentStepState?.getSelectedStepType() != null;

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: GestureDetector(
          onTap: _isLoading ? null : _handleCancelButtonPress,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.225),
              border: Border.all(color: Colors.white24, width: 1),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(
              // Use isStepTypeSelected for immediate update
              isStepTypeSelected ? Icons.edit : Icons.close,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Future<void> save() async {
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
          .map((stepWidget) => stepWidget.toPostStep())
          .where((step) => step != null)
          .cast<PostStep>()
          .toList();

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

  bool _validateSteps() {
    bool isValid = true;
    for (var i = 0; i < _stepKeys.length; i++) {
      final state = _stepKeys[i].currentState;
      if (state == null || !state.validate()) {
        isValid = false;
        print('Step ${i + 1} validation failed');
      }
    }
    return isValid;
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    String? label,
    bool isLarger = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isLarger
                  ? Colors.red.withOpacity(0.5)
                  : Colors.blue
                      .withOpacity(0.5), // Temporary colors for debugging
              border: Border.all(
                color: Colors.white.withOpacity(0.6),
                width: 1,
              ),
            ),
            child: Padding(
              padding: isLarger
                  ? const EdgeInsets.all(16)
                  : const EdgeInsets.all(12),
              child: Icon(icon, color: Colors.white, size: isLarger ? 28 : 24),
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFirstPage(double containerSize) {
    return Stack(
      children: [
        ListView(
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
            const SizedBox(height: 100),
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.yellow.withOpacity(0.5),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(containerSize * 0.5),
                bottomRight: Radius.circular(containerSize * 0.5),
              ),
              // TODO: Correct the shape of the button area to place buttons along the bottom border of the circular post_creation frame.
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.settings,
                  onPressed: () {
                    // TODO: Implement settings action
                  },
                  label: 'Settings',
                ),
                _buildActionButton(
                  icon: Icons.auto_awesome,
                  onPressed: () {
                    // TODO: Implement AI action
                  },
                  label: 'AI',
                  isLarger: true,
                ),
                _buildActionButton(
                  icon: _steps.isEmpty
                      ? Icons.add_circle
                      : Icons.format_list_numbered,
                  onPressed: _steps.isEmpty
                      ? _addStep
                      : () {
                          if (_currentPage < _steps.length) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                  label: _steps.isEmpty ? 'Add Step' : 'Steps',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width - 32;
    return ClipOval(
      child: Container(
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
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Form(
              key: _formKey,
              child: Center(
                child: SizedBox(
                  width: size * 0.8,
                  height: size * 0.8,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      _buildFirstPage(size),
                      ..._steps.map((step) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  const SizedBox(height: 40),
                                  step,
                                ],
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),
            // Navigation arrows
            if (_steps.isNotEmpty)
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _currentPage > 0
                      ? IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        )
                      : const SizedBox(width: 48),
                ),
              ),
            if (_steps.isNotEmpty)
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _currentPage < _steps.length
                      ? IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            if (_currentPage < _steps.length) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            _addStep();
                          },
                        ),
                ),
              ),
            // Cancel/Edit button
            if (_currentPage == 0) _buildCancelButton(),
            if (_currentPage > 0) _buildStepButton(),
          ],
        ),
      ),
    );
  }
}
