import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/constants.dart';
import '../models/invite_key_model.dart';
import 'auth_provider.dart';

final inviteKeysStreamProvider = StreamProvider.autoDispose<List<InviteKeyModel>>((ref) {
  return FirebaseFirestore.instance
      .collection(AppConstants.inviteKeysCollection)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(InviteKeyModel.fromFirestore).toList());
});

final inviteKeyRepositoryProvider = Provider<InviteKeyRepository>((ref) {
  return InviteKeyRepository(ref);
});

class InviteKeyRepository {
  final Ref _ref;
  InviteKeyRepository(this._ref);

  final _db = FirebaseFirestore.instance;
  static const _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  String _generateCode() {
    final rnd = const Uuid().v4().replaceAll('-', '').toUpperCase();
    final buffer = StringBuffer();
    for (var i = 0; i < 8; i++) {
      buffer.write(_alphabet[rnd.codeUnitAt(i) % _alphabet.length]);
    }
    return buffer.toString();
  }

  /// Cria uma nova família com sua chave principal.
  Future<String> createFamilyWithKey({
    required String familyName,
    required int maxUses,
  }) async {
    final uid = _ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) throw Exception('Sessão expirada.');

    final familyRef = _db.collection(AppConstants.familiesCollection).doc();
    final code = _generateCode();
    final keyRef = _db.collection(AppConstants.inviteKeysCollection).doc(code);

    await _db.runTransaction((tx) async {
      tx.set(familyRef, {
        'name': familyName,
        'createdBy': uid,
        'createdAt': Timestamp.now(),
      });
      tx.set(keyRef, InviteKeyModel(
        code: code,
        familyId: familyRef.id,
        familyName: familyName,
        maxUses: maxUses,
        usedCount: 0,
        active: true,
        createdBy: uid,
        createdAt: DateTime.now(),
      ).toFirestore());
    });

    return code;
  }

  /// Cria uma chave extra vinculada a uma família já existente.
  Future<String> createExtraKey({
    required String familyId,
    required String familyName,
    required int maxUses,
  }) async {
    final uid = _ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) throw Exception('Sessão expirada.');

    final code = _generateCode();
    final keyRef = _db.collection(AppConstants.inviteKeysCollection).doc(code);
    await keyRef.set(InviteKeyModel(
      code: code,
      familyId: familyId,
      familyName: familyName,
      maxUses: maxUses,
      usedCount: 0,
      active: true,
      createdBy: uid,
      createdAt: DateTime.now(),
    ).toFirestore());

    return code;
  }

  Future<void> setActive(String code, bool active) async {
    await _db.collection(AppConstants.inviteKeysCollection).doc(code).update({'active': active});
  }
}
