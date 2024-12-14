import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/step_type_repository.dart';
import '../models/step_type_model.dart';

class FirebaseStepTypeRepository implements StepTypeRepository {
  final FirebaseFirestore _firestore;

  FirebaseStepTypeRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<StepTypeModel>> getStepTypes() async {
    try {
      final snapshot = await _firestore.collection('stepTypes').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return StepTypeModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch step types: $e');
    }
  }

  @override
  Future<StepTypeModel> getStepTypeById(String id) async {
    try {
      final doc = await _firestore.collection('stepTypes').doc(id).get();
      if (!doc.exists) {
        throw Exception('Step type not found');
      }
      final data = doc.data()!;
      data['id'] = doc.id;
      return StepTypeModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch step type: $e');
    }
  }

  @override
  Future<void> createStepType(StepTypeModel stepType) async {
    try {
      await _firestore
          .collection('stepTypes')
          .doc(stepType.id)
          .set(stepType.toJson());
    } catch (e) {
      throw Exception('Failed to create step type: $e');
    }
  }

  @override
  Future<void> updateStepType(StepTypeModel stepType) async {
    try {
      await _firestore
          .collection('stepTypes')
          .doc(stepType.id)
          .update(stepType.toJson());
    } catch (e) {
      throw Exception('Failed to update step type: $e');
    }
  }

  @override
  Future<void> deleteStepType(String id) async {
    try {
      await _firestore.collection('stepTypes').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete step type: $e');
    }
  }
}
