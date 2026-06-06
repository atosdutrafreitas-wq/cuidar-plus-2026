import 'package:cloud_firestore/cloud_firestore.dart';

enum MedicationLogStatus { taken, missed, skipped }

class MedicationLogModel {
  final String id;
  final String medicationId;
  final String elderlyId;
  final String familyId;
  final String scheduledTime;
  final MedicationLogStatus status;
  final DateTime? takenAt;
  final String? notes;
  final DateTime createdAt;

  MedicationLogModel({
    required this.id,
    required this.medicationId,
    required this.elderlyId,
    required this.familyId,
    required this.scheduledTime,
    required this.status,
    this.takenAt,
    this.notes,
    required this.createdAt,
  });

  factory MedicationLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MedicationLogModel(
      id: doc.id,
      medicationId: data['medicationId'] ?? '',
      elderlyId: data['elderlyId'] ?? '',
      familyId: data['familyId'] ?? '',
      scheduledTime: data['scheduledTime'] ?? '',
      status: MedicationLogStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => MedicationLogStatus.missed,
      ),
      takenAt: (data['takenAt'] as Timestamp?)?.toDate(),
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'medicationId': medicationId,
        'elderlyId': elderlyId,
        'familyId': familyId,
        'scheduledTime': scheduledTime,
        'status': status.name,
        'takenAt': takenAt != null ? Timestamp.fromDate(takenAt!) : null,
        'notes': notes,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
