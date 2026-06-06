import 'package:cloud_firestore/cloud_firestore.dart';

enum AlertType { medication, help, missed }
enum AlertStatus { pending, acknowledged, dismissed }

class AlertModel {
  final String id;
  final String elderlyId;
  final String familyId;
  final AlertType type;
  final AlertStatus status;
  final String title;
  final String message;
  final String? medicationId;
  final DateTime scheduledFor;
  final DateTime? acknowledgedAt;
  final DateTime createdAt;

  AlertModel({
    required this.id,
    required this.elderlyId,
    required this.familyId,
    required this.type,
    required this.status,
    required this.title,
    required this.message,
    this.medicationId,
    required this.scheduledFor,
    this.acknowledgedAt,
    required this.createdAt,
  });

  factory AlertModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AlertModel(
      id: doc.id,
      elderlyId: data['elderlyId'] ?? '',
      familyId: data['familyId'] ?? '',
      type: AlertType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => AlertType.medication,
      ),
      status: AlertStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => AlertStatus.pending,
      ),
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      medicationId: data['medicationId'],
      scheduledFor:
          (data['scheduledFor'] as Timestamp?)?.toDate() ?? DateTime.now(),
      acknowledgedAt: (data['acknowledgedAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'elderlyId': elderlyId,
        'familyId': familyId,
        'type': type.name,
        'status': status.name,
        'title': title,
        'message': message,
        'medicationId': medicationId,
        'scheduledFor': Timestamp.fromDate(scheduledFor),
        'acknowledgedAt':
            acknowledgedAt != null ? Timestamp.fromDate(acknowledgedAt!) : null,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
