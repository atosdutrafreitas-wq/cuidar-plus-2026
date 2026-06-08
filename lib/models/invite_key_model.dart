import 'package:cloud_firestore/cloud_firestore.dart';

class InviteKeyModel {
  final String code;
  final String? familyId;
  final String familyName;
  final int maxUses;
  final int usedCount;
  final bool active;
  final String createdBy;
  final DateTime createdAt;

  InviteKeyModel({
    required this.code,
    this.familyId,
    required this.familyName,
    required this.maxUses,
    required this.usedCount,
    required this.active,
    required this.createdBy,
    required this.createdAt,
  });

  bool get isAvailable => active && usedCount < maxUses;
  int get remainingUses => maxUses - usedCount;

  factory InviteKeyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InviteKeyModel(
      code: doc.id,
      familyId: data['familyId'],
      familyName: data['familyName'] ?? '',
      maxUses: data['maxUses'] ?? 0,
      usedCount: data['usedCount'] ?? 0,
      active: data['active'] ?? true,
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'familyId': familyId,
        'familyName': familyName,
        'maxUses': maxUses,
        'usedCount': usedCount,
        'active': active,
        'createdBy': createdBy,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
