import '../../domain/repositories/step_type_repository.dart';
import '../models/step_type_model.dart';

class MockStepTypeRepository implements StepTypeRepository {
  final List<StepTypeModel> _stepTypes = [
    StepTypeModel(
      id: 'text',
      name: 'Text',
      description: 'A simple text step',
      icon: 'text_fields',
      color: '#4CAF50', // Green for text
      options: [
        StepTypeOption(
          id: 'text',
          label: 'Content',
          type: 'text',
          config: {'multiline': true},
        ),
      ],
    ),
    StepTypeModel(
      id: 'image',
      name: 'Image',
      description: 'An image with optional caption',
      icon: 'image',
      color: '#2196F3', // Blue for images
      options: [
        StepTypeOption(
          id: 'imageUrl',
          label: 'Image URL',
          type: 'text',
        ),
        StepTypeOption(
          id: 'caption',
          label: 'Caption',
          type: 'text',
        ),
      ],
    ),
    StepTypeModel(
      id: 'code',
      name: 'Code',
      description: 'A code snippet',
      icon: 'code',
      color: '#9C27B0', // Purple for code
      options: [
        StepTypeOption(
          id: 'code',
          label: 'Code',
          type: 'text',
          config: {
            'multiline': true,
            'monospace': true,
          },
        ),
        StepTypeOption(
          id: 'language',
          label: 'Language',
          type: 'select',
          config: {
            'options': [
              'javascript',
              'python',
              'java',
              'dart',
              'html',
              'css',
              'other',
            ],
          },
        ),
      ],
    ),
    StepTypeModel(
      id: 'video',
      name: 'Video',
      description: 'A video with optional description',
      icon: 'video_library',
      color: '#F44336', // Red for video
      options: [
        StepTypeOption(
          id: 'videoUrl',
          label: 'Video URL',
          type: 'text',
        ),
        StepTypeOption(
          id: 'description',
          label: 'Description',
          type: 'text',
          config: {'multiline': true},
        ),
      ],
    ),
  ];

  @override
  Future<List<StepTypeModel>> getStepTypes() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _stepTypes;
  }

  @override
  Future<StepTypeModel> getStepTypeById(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return _stepTypes.firstWhere(
      (type) => type.id == id,
      orElse: () => throw Exception('Step type not found'),
    );
  }

  @override
  Future<void> createStepType(StepTypeModel stepType) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (_stepTypes.any((type) => type.id == stepType.id)) {
      throw Exception('Step type with this ID already exists');
    }

    _stepTypes.add(stepType);
  }

  @override
  Future<void> updateStepType(StepTypeModel stepType) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _stepTypes.indexWhere((type) => type.id == stepType.id);
    if (index == -1) {
      throw Exception('Step type not found');
    }

    _stepTypes[index] = stepType;
  }

  @override
  Future<void> deleteStepType(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _stepTypes.indexWhere((type) => type.id == id);
    if (index == -1) {
      throw Exception('Step type not found');
    }

    _stepTypes.removeAt(index);
  }
}
