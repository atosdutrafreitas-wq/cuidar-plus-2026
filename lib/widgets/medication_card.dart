import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../models/medication_model.dart';
import '../providers/medication_provider.dart';

class MedicationCard extends ConsumerWidget {
  final MedicationModel medication;
  final String elderlyId;
  final String familyId;
  final bool showActions;
  final VoidCallback? onDelete;

  const MedicationCard({
    super.key,
    required this.medication,
    required this.elderlyId,
    required this.familyId,
    this.showActions = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasBeenTakenToday = medication.lastTaken != null &&
        _isToday(medication.lastTaken!);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: hasBeenTakenToday
                        ? AppTheme.primary.withOpacity(0.15)
                        : AppTheme.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    hasBeenTakenToday
                        ? Icons.check_circle
                        : Icons.medication,
                    color: hasBeenTakenToday
                        ? AppTheme.primary
                        : AppTheme.accent,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        medication.dosage,
                        style: const TextStyle(
                            fontSize: 16, color: AppTheme.textMedium),
                      ),
                    ],
                  ),
                ),
                if (showActions)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (v) {
                      if (v == 'delete') onDelete?.call();
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: AppTheme.danger),
                            SizedBox(width: 8),
                            Text('Remover', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: medication.scheduledTimes
                  .map((t) => _TimeChip(time: t))
                  .toList(),
            ),
            if (medication.instructions != null) ...[
              const SizedBox(height: 8),
              Text(
                medication.instructions!,
                style: const TextStyle(
                    fontSize: 15, color: AppTheme.textMedium, fontStyle: FontStyle.italic),
              ),
            ],
            const SizedBox(height: 12),
            if (!hasBeenTakenToday)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _markTaken(context, ref),
                  icon: const Icon(Icons.check, size: 24),
                  label: const Text('TOMEI',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppTheme.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppTheme.primary, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Tomada às ${DateFormat('HH:mm').format(medication.lastTaken!)}',
                      style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _markTaken(BuildContext context, WidgetRef ref) async {
    final time = medication.scheduledTimes.isNotEmpty
        ? medication.scheduledTimes.first
        : DateFormat('HH:mm').format(DateTime.now());

    await ref.read(medicationNotifierProvider.notifier).markTaken(
          medication.id,
          elderlyId,
          familyId,
          time,
        );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${medication.name} marcada como tomada!',
              style: const TextStyle(fontSize: 16)),
          backgroundColor: AppTheme.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

class _TimeChip extends StatelessWidget {
  final String time;
  const _TimeChip({required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time, size: 16, color: AppTheme.primary),
          const SizedBox(width: 4),
          Text(time,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary)),
        ],
      ),
    );
  }
}
