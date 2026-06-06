import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/verify_otp_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/elderly_home_screen.dart';
import '../screens/home/family_home_screen.dart';
import '../screens/medications/medication_list_screen.dart';
import '../screens/medications/add_medication_screen.dart';
import '../screens/alerts/alerts_screen.dart';
import '../screens/qr_code/qr_code_screen.dart';
import '../screens/qr_code/qr_profile_public_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/family/family_panel_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/ocr/ocr_receipt_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoading = authState.isLoading;
      final path = state.matchedLocation;

      if (isLoading) return '/splash';

      final authPaths = ['/login', '/verify-otp', '/register', '/splash'];
      final isAuthPath = authPaths.any((p) => path.startsWith(p));

      if (!isLoggedIn && !isAuthPath) return '/login';
      if (isLoggedIn && path == '/login') return '/home';

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/verify-otp',
        builder: (_, state) {
          final phone = state.extra as String? ?? '';
          return VerifyOtpScreen(phoneNumber: phone);
        },
      ),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (_, __) => const ElderlyHomeScreen()),
      GoRoute(
          path: '/family-home', builder: (_, __) => const FamilyHomeScreen()),
      GoRoute(
          path: '/medications',
          builder: (_, __) => const MedicationListScreen()),
      GoRoute(
          path: '/add-medication',
          builder: (_, __) => const AddMedicationScreen()),
      GoRoute(path: '/alerts', builder: (_, __) => const AlertsScreen()),
      GoRoute(path: '/qr-code', builder: (_, __) => const QrCodeScreen()),
      GoRoute(
        path: '/qr-profile/:elderlyId',
        builder: (_, state) {
          final id = state.pathParameters['elderlyId'] ?? '';
          return QrProfilePublicScreen(elderlyId: id);
        },
      ),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(
          path: '/family-panel',
          builder: (_, __) => const FamilyPanelScreen()),
      GoRoute(path: '/reports', builder: (_, __) => const ReportsScreen()),
      GoRoute(path: '/ocr', builder: (_, __) => const OcrReceiptScreen()),
    ],
  );
});
