import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';
import '../models/user_model.dart';
import '../models/invite_key_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc =
        await _db.collection(AppConstants.usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> createUserProfile(UserModel user) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(user.id)
        .set(user.toFirestore());
  }

  Future<void> updateUserProfile(UserModel user) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(user.id)
        .update(user.toFirestore());
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  bool get isLoggedIn => currentUser != null;

  /// Valida e consome uma chave de convite numa transação atômica,
  /// retornando o familyId vinculado a ela.
  Future<String> consumeInviteKey(String code) async {
    final ref = _db.collection(AppConstants.inviteKeysCollection).doc(code);
    return _db.runTransaction<String>((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        throw Exception('Chave de convite inválida.');
      }
      final key = InviteKeyModel.fromFirestore(snap);
      if (!key.isAvailable) {
        throw Exception('Esta chave atingiu o limite de cadastros ou foi desativada.');
      }
      tx.update(ref, {'usedCount': key.usedCount + 1});
      return key.familyId ?? '';
    });
  }

  Future<InviteKeyModel?> lookupInviteKey(String code) async {
    final doc =
        await _db.collection(AppConstants.inviteKeysCollection).doc(code).get();
    if (!doc.exists) return null;
    return InviteKeyModel.fromFirestore(doc);
  }
}
