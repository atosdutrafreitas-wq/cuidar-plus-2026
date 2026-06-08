import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProfileProvider =
    FutureProvider.autoDispose<UserModel?>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return null;
  return ref.watch(authServiceProvider).getUserProfile(user.uid);
});

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthService _service;

  AuthNotifier(this._service) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _service.authStateChanges.listen((user) async {
      if (user == null) {
        state = const AsyncValue.data(null);
        return;
      }
      try {
        final profile = await _service.getUserProfile(user.uid);
        state = AsyncValue.data(profile);
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      }
    });
  }

  Future<void> signUp({required String email, required String password}) async {
    await _service.signUp(email: email, password: password);
  }

  Future<void> signIn({required String email, required String password}) async {
    await _service.signIn(email: email, password: password);
  }

  /// Cria o perfil consumindo uma chave de convite (define a família automaticamente).
  Future<void> createProfileWithInviteKey({
    required String uid,
    required String email,
    required String name,
    required String role,
    required String inviteKeyCode,
    required String consentVersion,
  }) async {
    final familyId = await _service.consumeInviteKey(inviteKeyCode);
    final user = UserModel(
      id: uid,
      email: email,
      name: name,
      role: role,
      familyId: familyId.isEmpty ? null : familyId,
      createdAt: DateTime.now(),
      consentVersion: consentVersion,
      consentAt: DateTime.now(),
    );
    await _service.createUserProfile(user);
    state = AsyncValue.data(user);
  }

  Future<void> signOut() async {
    await _service.signOut();
    state = const AsyncValue.data(null);
  }

  /// LGPD: reautentica antes de operações sensíveis.
  Future<void> reauthenticate(String password) => _service.reauthenticate(password);

  /// LGPD (direito de eliminação): apaga o perfil e a conta do usuário.
  Future<void> deleteAccount() async {
    await _service.deleteAccount();
    state = const AsyncValue.data(null);
  }

  /// LGPD (direito de acesso/portabilidade): retorna os dados pessoais do usuário.
  Future<Map<String, dynamic>> exportUserData() => _service.exportUserData();
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});
