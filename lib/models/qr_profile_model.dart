import 'package:cloud_firestore/cloud_firestore.dart';

class QrProfileModel {
  final String id;
  final String elderlyId;
  final String name;
  final int age;
  final String? photoUrl;
  final String bloodType;
  final List<String> allergies;
  final String? healthPlan;
  final String? healthPlanCard;
  final String emergencyContact;
  final String emergencyPhone;
  final String? address;
  final List<QrMedication> medications;
  final bool isPublic;
  final DateTime updatedAt;

  QrProfileModel({
    required this.id,
    required this.elderlyId,
    required this.name,
    required this.age,
    this.photoUrl,
    required this.bloodType,
    required this.allergies,
    this.healthPlan,
    this.healthPlanCard,
    required this.emergencyContact,
    required this.emergencyPhone,
    this.address,
    required this.medications,
    this.isPublic = true,
    required this.updatedAt,
  });

  factory QrProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QrProfileModel(
      id: doc.id,
      elderlyId: data['elderlyId'] ?? '',
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      photoUrl: data['photoUrl'],
      bloodType: data['bloodType'] ?? '',
      allergies: List<String>.from(data['allergies'] ?? []),
      healthPlan: data['healthPlan'],
      healthPlanCard: data['healthPlanCard'],
      emergencyContact: data['emergencyContact'] ?? '',
      emergencyPhone: data['emergencyPhone'] ?? '',
      address: data['address'],
      medications: (data['medications'] as List<dynamic>? ?? [])
          .map((m) => QrMedication.fromMap(m as Map<String, dynamic>))
          .toList(),
      isPublic: data['isPublic'] ?? true,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'elderlyId': elderlyId,
        'name': name,
        'age': age,
        'photoUrl': photoUrl,
        'bloodType': bloodType,
        'allergies': allergies,
        'healthPlan': healthPlan,
        'healthPlanCard': healthPlanCard,
        'emergencyContact': emergencyContact,
        'emergencyPhone': emergencyPhone,
        'address': address,
        'medications': medications.map((m) => m.toMap()).toList(),
        'isPublic': isPublic,
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}

class QrMedication {
  final String name;
  final String dosage;
  final List<String> scheduledTimes;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? lastTaken;

  QrMedication({
    required this.name,
    required this.dosage,
    required this.scheduledTimes,
    required this.startDate,
    this.endDate,
    this.lastTaken,
  });

  factory QrMedication.fromMap(Map<String, dynamic> map) => QrMedication(
        name: map['name'] ?? '',
        dosage: map['dosage'] ?? '',
        scheduledTimes: List<String>.from(map['scheduledTimes'] ?? []),
        startDate:
            (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
        endDate: (map['endDate'] as Timestamp?)?.toDate(),
        lastTaken: (map['lastTaken'] as Timestamp?)?.toDate(),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'dosage': dosage,
        'scheduledTimes': scheduledTimes,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
        'lastTaken': lastTaken != null ? Timestamp.fromDate(lastTaken!) : null,
      };
}
