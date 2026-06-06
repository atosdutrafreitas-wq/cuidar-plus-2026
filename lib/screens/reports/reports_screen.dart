import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/medication_log_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/elderly_provider.dart';
import '../../providers/medication_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(authNotifierProvider).valueOrNull;
    final elderlyId =
        ref.watch(selectedElderlyIdProvider) ?? profile?.id ?? '';

    final meds = ref.watch(medicationsProvider(elderlyId));
    final logs = ref.watch(medicationLogsProvider(elderlyId));

    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Resumo dos últimos 7 dias',
                  style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              logs.when(
                data: (logList) {
                  final total = meds.valueOrNull?.fold<int>(
                          0, (s, m) => s + m.scheduledTimes.length * 7) ??
                      0;
                  final taken = logList
                      .where((l) => l.status == MedicationLogStatus.taken)
                      .length;
                  final missed = logList
                      .where((l) => l.status == MedicationLogStatus.missed)
                      .length;
                  final pct = total == 0 ? 0.0 : taken / total;

                  return Column(
                    children: [
                      _SummaryRow(
                          taken: taken, missed: missed, total: total, pct: pct),
                      const SizedBox(height: 24),
                      const Text('Histórico detalhado',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      if (logList.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text('Sem registros ainda',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: AppTheme.textMedium)),
                          ),
                        )
                      else
                        ...logList.take(30).map((log) => _LogTile(log: log)),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Erro: $e'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final int taken;
  final int missed;
  final int total;
  final double pct;

  const _SummaryRow({
    required this.taken,
    required this.missed,
    required this.total,
    required this.pct,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _StatCard(
                value: '$taken',
                label: 'Tomadas',
                color: AppTheme.primary,
                icon: Icons.check_circle),
            const SizedBox(width: 12),
            _StatCard(
                value: '$missed',
                label: 'Perdidas',
                color: AppTheme.danger,
                icon: Icons.cancel),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8)
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Adesão geral',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${(pct * 100).toInt()}%',
                      style: TextStyle(
                          fontSize: 24,
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
                minHeight: 14,
                borderRadius: BorderRadius.circular(7),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: color)),
                Text(label,
                    style: const TextStyle(
                        fontSize: 14, color: AppTheme.textMedium)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final MedicationLogModel log;
  const _LogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final isTaken = log.status == MedicationLogStatus.taken;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          isTaken ? Icons.check_circle : Icons.cancel,
          color: isTaken ? AppTheme.primary : AppTheme.danger,
          size: 28,
        ),
        title: Text(
          isTaken ? 'Tomada' : 'Perdida',
          style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isTaken ? AppTheme.primary : AppTheme.danger),
        ),
        subtitle: Text(
          DateFormat('dd/MM/yyyy HH:mm').format(log.createdAt),
          style: const TextStyle(fontSize: 15),
        ),
        trailing: Text(log.scheduledTime,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
