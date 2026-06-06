import 'package:cloud_firestore/cloud_firestore.dart';

class ElderlyModel {
  final String id;
  final String familyId;
  final String name;
  final DateTime birthDate;
  final String? photoUrl;
  final String bloodType;
  final List<String> allergies;
  final String? healthPlan;
  final String? healthPlanCard;
  final String emergencyContact;
  final String emergencyPhone;
  final String? address;
  final List<String> familyMemberIds;
  final List<String> caregiverIds;
  final DateTime createdAt;

  ElderlyModel({
    required this.id,
    required this.familyId,
    required this.name,
    required this.birthDate,
    this.photoUrl,
    required this.bloodType,
    required this.allergies,
    this.healthPlan,
    this.healthPlanCard,
    required this.emergencyContact,
    required this.emergencyPhone,
    this.address,
    required this.familyMemberIds,
    required this.caregiverIds,
    required this.createdAt,
  });

  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  factory ElderlyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ElderlyModel(
      id: doc.id,
      familyId: data['familyId'] ?? '',
      name: data['name'] ?? '',
      birthDate: (data['birthDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      photoUrl: data['photoUrl'],
      bloodType: data['bloodType'] ?? 'Não sei',
      allergies: List<String>.from(data['allergies'] ?? []),
      healthPlan: data['healthPlan'],
      healthPlanCard: data['healthPlanCard'],
      emergencyContact: data['emergencyContact'] ?? '',
      emergencyPhone: data['emergencyPhone'] ?? '',
      address: data['address'],
      familyMemberIds: List<String>.from(data['familyMemberIds'] ?? []),
      caregiverIds: List<String>.from(data['caregiverIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'familyId': familyId,
        'name': name,
        'birthDate': Timestamp.fromDate(birthDate),
        'photoUrl': photoUrl,
        'bloodType': bloodType,
        'allergies': allergies,
        'healthPlan': healthPlan,
        'healthPlanCard': healthPlanCard,
        'emergencyContact': emergencyContact,
        'emergencyPhone': emergencyPhone,
        'address': address,
        'familyMemberIds': familyMemberIds,
        'caregiverIds': caregiverIds,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
