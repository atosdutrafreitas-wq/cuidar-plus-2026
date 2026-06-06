import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String phone;
  final String name;
  final String role;
  final String? familyId;
  final String? photoUrl;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.phone,
    required this.name,
    required this.role,
    this.familyId,
    this.photoUrl,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      phone: data['phone'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'familiar',
      familyId: data['familyId'],
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'phone': phone,
        'name': name,
        'role': role,
        'familyId': familyId,
        'photoUrl': photoUrl,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  UserModel copyWith({
    String? name,
    String? role,
    String? familyId,
    String? photoUrl,
  }) =>
      UserModel(
        id: id,
        phone: phone,
        name: name ?? this.name,
        role: role ?? this.role,
        familyId: familyId ?? this.familyId,
        photoUrl: photoUrl ?? this.photoUrl,
        createdAt: createdAt,
      );
}
