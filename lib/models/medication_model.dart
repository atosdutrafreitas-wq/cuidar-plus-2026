import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationModel {
  final String id;
  final String elderlyId;
  final String familyId;
  final String name;
  final String dosage;
  final String frequency;
  final List<String> scheduledTimes;
  final DateTime startDate;
  final DateTime? endDate;
  final String? instructions;
  final String? photoUrl;
  final bool isActive;
  final AlertConfig alertConfig;
  final DateTime? lastTaken;
  final DateTime createdAt;

  MedicationModel({
    required this.id,
    required this.elderlyId,
    required this.familyId,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.scheduledTimes,
    required this.startDate,
    this.endDate,
    this.instructions,
    this.photoUrl,
    this.isActive = true,
    required this.alertConfig,
    this.lastTaken,
    required this.createdAt,
  });

  factory MedicationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MedicationModel(
      id: doc.id,
      elderlyId: data['elderlyId'] ?? '',
      familyId: data['familyId'] ?? '',
      name: data['name'] ?? '',
      dosage: data['dosage'] ?? '',
      frequency: data['frequency'] ?? '',
      scheduledTimes: List<String>.from(data['scheduledTimes'] ?? []),
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      instructions: data['instructions'],
      photoUrl: data['photoUrl'],
      isActive: data['isActive'] ?? true,
      alertConfig: AlertConfig.fromMap(
          data['alertConfig'] as Map<String, dynamic>? ?? {}),
      lastTaken: (data['lastTaken'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'elderlyId': elderlyId,
        'familyId': familyId,
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'scheduledTimes': scheduledTimes,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
        'instructions': instructions,
        'photoUrl': photoUrl,
        'isActive': isActive,
        'alertConfig': alertConfig.toMap(),
        'lastTaken': lastTaken != null ? Timestamp.fromDate(lastTaken!) : null,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

class AlertConfig {
  final int minutesBefore1;
  final int minutesBefore2;
  final int repeatEveryMinutes;
  final int maxRepeats;

  const AlertConfig({
    this.minutesBefore1 = 30,
    this.minutesBefore2 = 2,
    this.repeatEveryMinutes = 5,
    this.maxRepeats = 6,
  });

  factory AlertConfig.fromMap(Map<String, dynamic> map) => AlertConfig(
        minutesBefore1: map['minutesBefore1'] ?? 30,
        minutesBefore2: map['minutesBefore2'] ?? 2,
        repeatEveryMinutes: map['repeatEveryMinutes'] ?? 5,
        maxRepeats: map['maxRepeats'] ?? 6,
      );

  Map<String, dynamic> toMap() => {
        'minutesBefore1': minutesBefore1,
        'minutesBefore2': minutesBefore2,
        'repeatEveryMinutes': repeatEveryMinutes,
        'maxRepeats': maxRepeats,
      };
}
