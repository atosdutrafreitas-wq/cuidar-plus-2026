import '../models/medication_model.dart';
import '../models/medication_log_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class MedicationRepository {
  final FirestoreService _service;
  final NotificationService _notifications;

  MedicationRepository(this._service, this._notifications);

  Stream<List<MedicationModel>> watchMedications(String elderlyId) =>
      _service.medicationsStream(elderlyId);

  Stream<List<MedicationLogModel>> watchLogs(String elderlyId, {int days = 7}) =>
      _service.logsStream(elderlyId, days: days);

  Future<void> add(MedicationModel med, String elderlyName) async {
    final id = await _service.addMedication(med);
    final saved = MedicationModel(
      id: id,
      elderlyId: med.elderlyId,
      familyId: med.familyId,
      name: med.name,
      dosage: med.dosage,
      frequency: med.frequency,
      scheduledTimes: med.scheduledTimes,
      startDate: med.startDate,
      endDate: med.endDate,
      instructions: med.instructions,
      photoUrl: med.photoUrl,
      isActive: med.isActive,
      alertConfig: med.alertConfig,
      lastTaken: med.lastTaken,
      createdAt: med.createdAt,
    );
    await _notifications.scheduleMedicationAlerts(
      medication: saved,
      elderlyName: elderlyName,
    );
  }

  Future<void> markTaken(String medicationId, String elderlyId,
      String familyId, String scheduledTime) async {
    await _service.markMedicationTaken(
        medicationId, elderlyId, familyId, scheduledTime);
  }

  Future<void> deactivate(String id) async {
    await _service.deactivateMedication(id);
    await _notifications.cancelMedicationAlerts(id);
  }
}
