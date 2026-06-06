import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/alert_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/alert_provider.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(authNotifierProvider).valueOrNull;
    final familyId = profile?.familyId ?? profile?.id ?? '';
    final alerts = ref.watch(alertsProvider(familyId));

    return Scaffold(
      appBar: AppBar(title: const Text('Alertas')),
      body: SafeArea(
        child: alerts.when(
          data: (list) {
            if (list.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none,
                        size: 80, color: Color(0xFFBDBDBD)),
                    SizedBox(height: 16),
                    Text('Nenhum alerta pendente',
                        style:
                            TextStyle(fontSize: 20, color: AppTheme.textMedium)),
                  ],
                ),
              );
            }

            final helpAlerts = list.where((a) => a.type == AlertType.help).toList();
            final medAlerts =
                list.where((a) => a.type == AlertType.medication).toList();
            final missedAlerts =
                list.where((a) => a.type == AlertType.missed).toList();

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (helpAlerts.isNotEmpty) ...[
                  _SectionHeader(
                      label: 'PEDIDOS DE AJUDA', color: AppTheme.danger),
                  const SizedBox(height: 8),
                  ...helpAlerts.map(
                      (a) => _AlertCard(alert: a, onAck: () => _ack(ref, a.id))),
                  const SizedBox(height: 20),
                ],
                if (missedAlerts.isNotEmpty) ...[
                  _SectionHeader(
                      label: 'MEDICAÇÕES PERDIDAS', color: AppTheme.accent),
                  const SizedBox(height: 8),
                  ...missedAlerts.map(
                      (a) => _AlertCard(alert: a, onAck: () => _ack(ref, a.id))),
                  const SizedBox(height: 20),
                ],
                if (medAlerts.isNotEmpty) ...[
                  _SectionHeader(label: 'MEDICAÇÕES', color: AppTheme.primary),
                  const SizedBox(height: 8),
                  ...medAlerts.map(
                      (a) => _AlertCard(alert: a, onAck: () => _ack(ref, a.id))),
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erro: $e')),
        ),
      ),
    );
  }

  Future<void> _ack(WidgetRef ref, String id) async {
    await ref.read(alertNotifierProvider.notifier).acknowledge(id);
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color color;

  const _SectionHeader({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 20, color: color,
            margin: const EdgeInsets.only(right: 10)),
        Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 1)),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback onAck;

  const _AlertCard({required this.alert, required this.onAck});

  @override
  Widget build(BuildContext context) {
    final isHelp = alert.type == AlertType.help;
    final color = isHelp ? AppTheme.danger : AppTheme.primary;
    final icon = isHelp ? Icons.warning : Icons.notifications;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: isHelp ? const Color(0xFFFFF3F3) : null,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(alert.title,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isHelp ? AppTheme.danger : AppTheme.textDark)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alert.message, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd/MM - HH:mm').format(alert.createdAt),
              style:
                  const TextStyle(fontSize: 13, color: AppTheme.textMedium),
            ),
          ],
        ),
        trailing: TextButton(
          onPressed: onAck,
          child: Text(isHelp ? 'Atender' : 'OK',
              style: TextStyle(
                  fontSize: 16,
                  color: color,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
