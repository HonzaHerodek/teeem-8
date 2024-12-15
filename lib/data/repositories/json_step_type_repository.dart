import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../domain/repositories/step_type_repository.dart';
import '../models/step_type_model.dart';

class JsonStepTypeRepository implements StepTypeRepository {
  static const String _fileName = 'step_types.json';

  Future<File> get _file async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  Future<List<StepTypeModel>> _readStepTypes() async {
    try {
      final file = await _file;
      if (!await file.exists()) {
        await _writeStepTypes([]);
        return [];
      }

      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents) as List<dynamic>;
      return jsonList
          .map((json) => StepTypeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to read step types: $e');
    }
  }

  Future<void> _writeStepTypes(List<StepTypeModel> stepTypes) async {
    try {
      final file = await _file;
      final jsonList = stepTypes.map((type) => type.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      throw Exception('Failed to write step types: $e');
    }
  }

  @override
  Future<List<StepTypeModel>> getStepTypes() async {
    return _readStepTypes();
  }

  @override
  Future<StepTypeModel> getStepTypeById(String id) async {
    final stepTypes = await _readStepTypes();
    final stepType = stepTypes.firstWhere(
      (type) => type.id == id,
      orElse: () => throw Exception('Step type not found'),
    );
    return stepType;
  }

  @override
  Future<void> createStepType(StepTypeModel stepType) async {
    final stepTypes = await _readStepTypes();
    if (stepTypes.any((type) => type.id == stepType.id)) {
      throw Exception('Step type with this ID already exists');
    }
    stepTypes.add(stepType);
    await _writeStepTypes(stepTypes);
  }

  @override
  Future<void> updateStepType(StepTypeModel stepType) async {
    final stepTypes = await _readStepTypes();
    final index = stepTypes.indexWhere((type) => type.id == stepType.id);
    if (index == -1) {
      throw Exception('Step type not found');
    }
    stepTypes[index] = stepType;
    await _writeStepTypes(stepTypes);
  }

  @override
  Future<void> deleteStepType(String id) async {
    final stepTypes = await _readStepTypes();
    stepTypes.removeWhere((type) => type.id == id);
    await _writeStepTypes(stepTypes);
  }

  // Initialize with default step types if none exist
  Future<void> initializeDefaultTypes() async {
    final stepTypes = await _readStepTypes();
    if (stepTypes.isEmpty) {
      final defaults = [
        StepTypeModel(
          id: 'text',
          name: 'Text',
          description: 'A simple text step',
          icon: 'text_fields',
          color: '#4CAF50', // Green for text
          options: [
            StepTypeOption(
              id: 'content',
              label: 'Content',
              type: 'text',
              config: {'multiline': true},
            ),
          ],
        ),
        StepTypeModel(
          id: 'image',
          name: 'Image',
          description: 'An image with caption',
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
          description: 'Code snippet with syntax highlighting',
          icon: 'code',
          color: '#9C27B0', // Purple for code
          options: [
            StepTypeOption(
              id: 'language',
              label: 'Language',
              type: 'select',
              config: {
                'options': ['javascript', 'python', 'java', 'cpp', 'other'],
              },
            ),
            StepTypeOption(
              id: 'code',
              label: 'Code',
              type: 'text',
              config: {'multiline': true, 'monospace': true},
            ),
          ],
        ),
      ];

      for (final type in defaults) {
        await createStepType(type);
      }
    }
  }
}
