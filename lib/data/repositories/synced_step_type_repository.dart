import '../../core/errors/app_exception.dart';
import '../../core/services/connectivity_service.dart';
import '../../domain/repositories/step_type_repository.dart';
import '../models/step_type_model.dart';

class SyncedStepTypeRepository implements StepTypeRepository {
  final StepTypeRepository _onlineRepository;
  final StepTypeRepository _offlineRepository;
  final ConnectivityService _connectivityService;

  SyncedStepTypeRepository({
    required StepTypeRepository onlineRepository,
    required StepTypeRepository offlineRepository,
    required ConnectivityService connectivityService,
  })  : _onlineRepository = onlineRepository,
        _offlineRepository = offlineRepository,
        _connectivityService = connectivityService;

  /// Get the appropriate repository based on connectivity
  StepTypeRepository get _activeRepository =>
      _connectivityService.isOnline ? _onlineRepository : _offlineRepository;

  @override
  Future<List<StepTypeModel>> getStepTypes() async {
    try {
      return await _activeRepository.getStepTypes();
    } catch (e) {
      throw AppException('Failed to fetch step types: ${e.toString()}');
    }
  }

  @override
  Future<StepTypeModel> getStepTypeById(String id) async {
    try {
      return await _activeRepository.getStepTypeById(id);
    } catch (e) {
      throw AppException('Failed to fetch step type: ${e.toString()}');
    }
  }

  @override
  Future<void> createStepType(StepTypeModel stepType) async {
    try {
      await _activeRepository.createStepType(stepType);
      if (_connectivityService.isOnline) {
        await _offlineRepository.createStepType(stepType);
      }
    } catch (e) {
      throw AppException('Failed to create step type: ${e.toString()}');
    }
  }

  @override
  Future<void> updateStepType(StepTypeModel stepType) async {
    try {
      await _activeRepository.updateStepType(stepType);
      if (_connectivityService.isOnline) {
        await _offlineRepository.updateStepType(stepType);
      }
    } catch (e) {
      throw AppException('Failed to update step type: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteStepType(String id) async {
    try {
      await _activeRepository.deleteStepType(id);
      if (_connectivityService.isOnline) {
        await _offlineRepository.deleteStepType(id);
      }
    } catch (e) {
      throw AppException('Failed to delete step type: ${e.toString()}');
    }
  }
}
