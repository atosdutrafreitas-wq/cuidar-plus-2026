import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/elderly_provider.dart';
import '../../providers/medication_provider.dart';
import '../../widgets/medication_card.dart';

class MedicationListScreen extends ConsumerWidget {
  const MedicationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(authNotifierProvider).valueOrNull;
    final elderlyId = ref.watch(selectedElderlyIdProvider) ?? profile?.id ?? '';
    final familyId = profile?.familyId ?? profile?.id ?? '';
    final meds = ref.watch(medicationsProvider(elderlyId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt, size: 28),
            tooltip: 'Escanear receita',
            onPressed: () => context.push('/ocr'),
          ),
        ],
      ),
      body: SafeArea(
        child: meds.when(
          data: (list) {
            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.medication_outlined,
                        size: 80, color: Color(0xFFBDBDBD)),
                    const SizedBox(height: 16),
                    const Text('Nenhuma medicação ativa',
                        style: TextStyle(
                            fontSize: 20, color: AppTheme.textMedium)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/add-medication'),
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar medicação'),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => MedicationCard(
                medication: list[i],
                elderlyId: elderlyId,
                familyId: familyId,
                showActions: true,
                onDelete: () async {
                  final ok = await _confirmDelete(context);
                  if (ok) {
                    await ref
                        .read(medicationNotifierProvider.notifier)
                        .deactivate(list[i].id);
                  }
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) =>
              Center(child: Text('Erro ao carregar: $e')),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-medication'),
        icon: const Icon(Icons.add),
        label: const Text('Nova medicação', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Remover medicação?',
                style: TextStyle(fontSize: 20)),
            content: const Text(
                'A medicação será marcada como inativa.',
                style: TextStyle(fontSize: 18)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style:
                    ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
                child: const Text('Remover', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ) ??
        false;
  }
}
