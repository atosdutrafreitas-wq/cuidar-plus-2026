import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String phone;
  final String name;
  final String role;
  final String? familyId;
  final String? photoUrl;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.phone = '',
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
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'familiar',
      familyId: data['familyId'],
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'email': email,
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
        email: email,
        phone: phone,
        name: name ?? this.name,
        role: role ?? this.role,
        familyId: familyId ?? this.familyId,
        photoUrl: photoUrl ?? this.photoUrl,
        createdAt: createdAt,
      );
}
