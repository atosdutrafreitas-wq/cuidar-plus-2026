import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';

class UserModel {
  final String id;
  final String email;
  final String phone;
  final String name;
  final String role;
  final String? familyId;
  final String? photoUrl;
  final DateTime createdAt;
  final String consentVersion;
  final DateTime? consentAt;

  UserModel({
    required this.id,
    required this.email,
    this.phone = '',
    required this.name,
    required this.role,
    this.familyId,
    this.photoUrl,
    required this.createdAt,
    this.consentVersion = '',
    this.consentAt,
  });

  /// LGPD: indica se o usuário aceitou a versão vigente da Política de Privacidade.
  bool get hasCurrentConsent =>
      consentAt != null && consentVersion == AppConstants.privacyPolicyVersion;

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
      consentVersion: data['consentVersion'] ?? '',
      consentAt: (data['consentAt'] as Timestamp?)?.toDate(),
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
        'consentVersion': consentVersion,
        'consentAt': consentAt == null ? null : Timestamp.fromDate(consentAt!),
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
        consentVersion: consentVersion,
        consentAt: consentAt,
      );
}
