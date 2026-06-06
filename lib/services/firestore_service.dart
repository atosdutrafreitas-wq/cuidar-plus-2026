import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';
import '../models/elderly_model.dart';
import '../models/medication_model.dart';
import '../models/medication_log_model.dart';
import '../models/alert_model.dart';
import '../models/qr_profile_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Elderly ───────────────────────────────────────────────────────────────

  Stream<List<ElderlyModel>> elderlyStream(String familyId) {
    return _db
        .collection(AppConstants.elderlyCollection)
        .where('familyId', isEqualTo: familyId)
        .snapshots()
        .map((s) => s.docs.map(ElderlyModel.fromFirestore).toList());
  }

  Future<ElderlyModel?> getElderly(String id) async {
    final doc =
        await _db.collection(AppConstants.elderlyCollection).doc(id).get();
    if (!doc.exists) return null;
    return ElderlyModel.fromFirestore(doc);
  }

  Future<String> addElderly(ElderlyModel elderly) async {
    final ref = await _db
        .collection(AppConstants.elderlyCollection)
        .add(elderly.toFirestore());
    return ref.id;
  }

  Future<void> updateElderly(ElderlyModel elderly) async {
    await _db
        .collection(AppConstants.elderlyCollection)
        .doc(elderly.id)
        .update(elderly.toFirestore());
  }

  // ── Medications ───────────────────────────────────────────────────────────

  Stream<List<MedicationModel>> medicationsStream(String elderlyId) {
    return _db
        .collection(AppConstants.medicationsCollection)
        .where('elderlyId', isEqualTo: elderlyId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((s) => s.docs.map(MedicationModel.fromFirestore).toList());
  }

  Future<String> addMedication(MedicationModel med) async {
    final ref = await _db
        .collection(AppConstants.medicationsCollection)
        .add(med.toFirestore());
    return ref.id;
  }

  Future<void> updateMedication(MedicationModel med) async {
    await _db
        .collection(AppConstants.medicationsCollection)
        .doc(med.id)
        .update(med.toFirestore());
  }

  Future<void> deactivateMedication(String id) async {
    await _db
        .collection(AppConstants.medicationsCollection)
        .doc(id)
        .update({'isActive': false});
  }

  Future<void> markMedicationTaken(String medicationId, String elderlyId,
      String familyId, String scheduledTime) async {
    final now = DateTime.now();

    final log = MedicationLogModel(
      id: '',
      medicationId: medicationId,
      elderlyId: elderlyId,
      familyId: familyId,
      scheduledTime: scheduledTime,
      status: MedicationLogStatus.taken,
      takenAt: now,
      createdAt: now,
    );

    await _db
        .collection(AppConstants.medicationLogsCollection)
        .add(log.toFirestore());

    await _db
        .collection(AppConstants.medicationsCollection)
        .doc(medicationId)
        .update({'lastTaken': Timestamp.fromDate(now)});
  }

  // ── Logs ──────────────────────────────────────────────────────────────────

  Stream<List<MedicationLogModel>> logsStream(String elderlyId,
      {int days = 7}) {
    final since = DateTime.now().subtract(Duration(days: days));
    return _db
        .collection(AppConstants.medicationLogsCollection)
        .where('elderlyId', isEqualTo: elderlyId)
        .where('createdAt', isGreaterThan: Timestamp.fromDate(since))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(MedicationLogModel.fromFirestore).toList());
  }

  // ── Alerts ────────────────────────────────────────────────────────────────

  Stream<List<AlertModel>> alertsStream(String familyId) {
    return _db
        .collection(AppConstants.alertsCollection)
        .where('familyId', isEqualTo: familyId)
        .where('status', isEqualTo: AlertStatus.pending.name)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map(AlertModel.fromFirestore).toList());
  }

  Future<void> addAlert(AlertModel alert) async {
    await _db
        .collection(AppConstants.alertsCollection)
        .add(alert.toFirestore());
  }

  Future<void> acknowledgeAlert(String alertId) async {
    await _db.collection(AppConstants.alertsCollection).doc(alertId).update({
      'status': AlertStatus.acknowledged.name,
      'acknowledgedAt': Timestamp.now(),
    });
  }

  // ── QR Profile ────────────────────────────────────────────────────────────

  Future<QrProfileModel?> getQrProfile(String elderlyId) async {
    final snap = await _db
        .collection(AppConstants.qrProfilesCollection)
        .where('elderlyId', isEqualTo: elderlyId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return QrProfileModel.fromFirestore(snap.docs.first);
  }

  Future<void> upsertQrProfile(QrProfileModel profile) async {
    final snap = await _db
        .collection(AppConstants.qrProfilesCollection)
        .where('elderlyId', isEqualTo: profile.elderlyId)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) {
      await _db
          .collection(AppConstants.qrProfilesCollection)
          .add(profile.toFirestore());
    } else {
      await snap.docs.first.reference.update(profile.toFirestore());
    }
  }
}
