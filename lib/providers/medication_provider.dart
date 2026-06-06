import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medication_model.dart';
import '../models/medication_log_model.dart';
import '../repositories/medication_repository.dart';
import '../services/notification_service.dart';
import 'elderly_provider.dart';

final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());

final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  return MedicationRepository(
    ref.watch(firestoreServiceProvider),
    ref.watch(notificationServiceProvider),
  );
});

final medicationsProvider =
    StreamProvider.family<List<MedicationModel>, String>((ref, elderlyId) {
  return ref.watch(medicationRepositoryProvider).watchMedications(elderlyId);
});

final medicationLogsProvider =
    StreamProvider.family<List<MedicationLogModel>, String>((ref, elderlyId) {
  return ref.watch(medicationRepositoryProvider).watchLogs(elderlyId);
});

class MedicationNotifier extends StateNotifier<AsyncValue<void>> {
  final MedicationRepository _repo;
  MedicationNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<void> add(MedicationModel med, String elderlyName) async {
    state = const AsyncValue.loading();
    try {
      await _repo.add(med, elderlyName);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markTaken(String medicationId, String elderlyId,
      String familyId, String scheduledTime) async {
    await _repo.markTaken(medicationId, elderlyId, familyId, scheduledTime);
  }

  Future<void> deactivate(String id) async {
    await _repo.deactivate(id);
  }
}

final medicationNotifierProvider =
    StateNotifierProvider<MedicationNotifier, AsyncValue<void>>((ref) {
  return MedicationNotifier(ref.watch(medicationRepositoryProvider));
});
