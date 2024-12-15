import '../../data/models/step_type_model.dart';

abstract class StepTypeRepository {
  Future<List<StepTypeModel>> getStepTypes();
  Future<StepTypeModel> getStepTypeById(String id);
  Future<void> createStepType(StepTypeModel stepType);
  Future<void> updateStepType(StepTypeModel stepType);
  Future<void> deleteStepType(String id);
}
