import '../models/elderly_model.dart';
import '../services/firestore_service.dart';

class ElderlyRepository {
  final FirestoreService _service;
  ElderlyRepository(this._service);

  Stream<List<ElderlyModel>> watchFamily(String familyId) =>
      _service.elderlyStream(familyId);

  Future<ElderlyModel?> getById(String id) => _service.getElderly(id);

  Future<String> add(ElderlyModel elderly) => _service.addElderly(elderly);

  Future<void> update(ElderlyModel elderly) => _service.updateElderly(elderly);
}
