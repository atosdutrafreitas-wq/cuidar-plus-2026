import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/elderly_provider.dart';
import '../../providers/medication_provider.dart';
import '../../providers/alert_provider.dart';

class FamilyPanelScreen extends ConsumerWidget {
  const FamilyPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(authNotifierProvider).valueOrNull;
    final familyId = profile?.familyId ?? profile?.id ?? '';
    final elderly = ref.watch(elderlyListProvider(familyId));
    final alerts = ref.watch(alertsProvider(familyId));

    return Scaffold(
      appBar: AppBar(title: const Text('Painel Familiar')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AlertsSummary(alerts: alerts),
              const SizedBox(height: 20),
              const Text('Adesão por idoso',
                  style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              elderly.when(
                data: (list) => Column(
                  children: list
                      .map((e) => _ElderlyAdherenceCard(
                            elderlyId: e.id,
                            name: e.name,
                          ))
                      .toList(),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Erro: $e'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertsSummary extends ConsumerWidget {
  final AsyncValue<dynamic> alerts;
  const _AlertsSummary({required this.alerts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return alerts.when(
      data: (list) {
        final count = (list as List).length;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: count > 0
                ? AppTheme.accent.withOpacity(0.1)
                : AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: count > 0
                    ? AppTheme.accent.withOpacity(0.3)
                    : AppTheme.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                count > 0 ? Icons.notifications_active : Icons.check_circle,
                size: 40,
                color: count > 0 ? AppTheme.accent : AppTheme.primary,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    count > 0 ? '$count alertas pendentes' : 'Tudo em dia!',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    DateFormat("dd/MM 'às' HH:mm").format(DateTime.now()),
                    style: const TextStyle(
                        fontSize: 15, color: AppTheme.textMedium),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _ElderlyAdherenceCard extends ConsumerWidget {
  final String elderlyId;
  final String name;

  const _ElderlyAdherenceCard({
    required this.elderlyId,
    required this.name,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meds = ref.watch(medicationsProvider(elderlyId));
    final logs = ref.watch(medicationLogsProvider(elderlyId));

    final total = meds.valueOrNull?.fold<int>(
            0, (s, m) => s + m.scheduledTimes.length) ??
        0;
    final taken =
        logs.valueOrNull?.where((l) => l.status.name == 'taken').length ??
            0;
    final pct = total == 0 ? 0.0 : taken / total;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.elderly, color: AppTheme.primary, size: 28),
                const SizedBox(width: 10),
                Text(name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${(pct * 100).toInt()}%',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: pct >= 0.8
                            ? AppTheme.primary
                            : pct >= 0.5
                                ? AppTheme.accent
                                : AppTheme.danger)),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: pct,
              backgroundColor: const Color(0xFFE0E0E0),
              color: pct >= 0.8
                  ? AppTheme.primary
                  : pct >= 0.5
                      ? AppTheme.accent
                      : AppTheme.danger,
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 8),
            Text('$taken de $total medicações tomadas hoje',
                style: const TextStyle(
                    fontSize: 15, color: AppTheme.textMedium)),
          ],
        ),
      ),
    );
  }
}
