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
  String? _verificationId;

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

  Future<void> sendOtp(String phone) async {
    await _service.sendOtp(
      phoneNumber: phone,
      onCodeSent: (id) => _verificationId = id,
      onError: (e) => state = AsyncValue.error(e, StackTrace.current),
    );
  }

  Future<bool> verifyOtp(String code) async {
    try {
      final credential = await _service.verifyOtp(code);
      return credential != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> createProfile({
    required String uid,
    required String phone,
    required String name,
    required String role,
  }) async {
    final user = UserModel(
      id: uid,
      phone: phone,
      name: name,
      role: role,
      createdAt: DateTime.now(),
    );
    await _service.createUserProfile(user);
    state = AsyncValue.data(user);
  }

  Future<void> signOut() async {
    await _service.signOut();
    state = const AsyncValue.data(null);
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});
