import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/elderly_model.dart';
import '../services/firestore_service.dart';
import '../repositories/elderly_repository.dart';

final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

final elderlyRepositoryProvider = Provider<ElderlyRepository>((ref) {
  return ElderlyRepository(ref.watch(firestoreServiceProvider));
});

final selectedElderlyIdProvider = StateProvider<String?>((ref) => null);

final elderlyListProvider =
    StreamProvider.family<List<ElderlyModel>, String>((ref, familyId) {
  return ref.watch(elderlyRepositoryProvider).watchFamily(familyId);
});

final selectedElderlyProvider =
    FutureProvider.autoDispose<ElderlyModel?>((ref) async {
  final id = ref.watch(selectedElderlyIdProvider);
  if (id == null) return null;
  return ref.watch(elderlyRepositoryProvider).getById(id);
});

class ElderlyNotifier extends StateNotifier<AsyncValue<void>> {
  final ElderlyRepository _repo;
  ElderlyNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<String?> add(ElderlyModel elderly) async {
    state = const AsyncValue.loading();
    try {
      final id = await _repo.add(elderly);
      state = const AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<void> update(ElderlyModel elderly) async {
    state = const AsyncValue.loading();
    try {
      await _repo.update(elderly);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final elderlyNotifierProvider =
    StateNotifierProvider<ElderlyNotifier, AsyncValue<void>>((ref) {
  return ElderlyNotifier(ref.watch(elderlyRepositoryProvider));
});
