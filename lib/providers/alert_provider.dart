import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/alert_model.dart';
import '../repositories/alert_repository.dart';
import 'elderly_provider.dart';
import 'medication_provider.dart';

final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  return AlertRepository(
    ref.watch(firestoreServiceProvider),
    ref.watch(notificationServiceProvider),
  );
});

final alertsProvider =
    StreamProvider.family<List<AlertModel>, String>((ref, familyId) {
  return ref.watch(alertRepositoryProvider).watchAlerts(familyId);
});

class AlertNotifier extends StateNotifier<AsyncValue<void>> {
  final AlertRepository _repo;
  AlertNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<void> sendHelp({
    required String elderlyId,
    required String familyId,
    required String elderlyName,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repo.sendHelpAlert(
        elderlyId: elderlyId,
        familyId: familyId,
        elderlyName: elderlyName,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> acknowledge(String alertId) async {
    await _repo.acknowledge(alertId);
  }
}

final alertNotifierProvider =
    StateNotifierProvider<AlertNotifier, AsyncValue<void>>((ref) {
  return AlertNotifier(ref.watch(alertRepositoryProvider));
});
