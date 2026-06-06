import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medication_provider.dart';
import '../../providers/elderly_provider.dart';
import '../../providers/alert_provider.dart';
import '../../widgets/medication_card.dart';
import '../../widgets/help_button.dart';

class ElderlyHomeScreen extends ConsumerWidget {
  const ElderlyHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(authNotifierProvider).valueOrNull;
    final elderlyId = ref.watch(selectedElderlyIdProvider) ?? profile?.id ?? '';
    final meds = ref.watch(medicationsProvider(elderlyId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuidar+'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, size: 30),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _Header(name: profile?.name ?? 'Olá'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _TodaySummary(elderlyId: elderlyId),
                    const SizedBox(height: 24),
                    const Text('Medicações de hoje',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    meds.when(
                      data: (list) => list.isEmpty
                          ? const _EmptyMeds()
                          : Column(
                              children: list
                                  .map((m) => MedicationCard(
                                        medication: m,
                                        elderlyId: elderlyId,
                                        familyId: profile?.familyId ?? '',
                                      ))
                                  .toList(),
                            ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Erro: $e'),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'add_med',
            onPressed: () => context.push('/add-medication'),
            icon: const Icon(Icons.add),
            label: const Text('Medicação', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 12),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: 0,
        onTap: (i) => _onNavTap(context, i),
      ),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        context.push('/medications');
        break;
      case 2:
        context.push('/alerts');
        break;
      case 3:
        context.push('/qr-code');
        break;
    }
  }
}

class _Header extends StatelessWidget {
  final String name;
  const _Header({required this.name});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Bom dia'
        : now.hour < 18
            ? 'Boa tarde'
            : 'Boa noite';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$greeting,',
              style: const TextStyle(fontSize: 20, color: Colors.white70)),
          Text(name,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Text(
            DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(now),
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          const HelpButton(),
        ],
      ),
    );
  }
}

class _TodaySummary extends ConsumerWidget {
  final String elderlyId;
  const _TodaySummary({required this.elderlyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(medicationLogsProvider(elderlyId));
    final meds = ref.watch(medicationsProvider(elderlyId));

    final total = meds.valueOrNull?.fold<int>(
            0, (sum, m) => sum + m.scheduledTimes.length) ??
        0;
    final taken = logs.valueOrNull
            ?.where((l) => l.status.name == 'taken')
            .length ??
        0;

    return Row(
      children: [
        _SummaryCard(
          value: '$taken',
          label: 'Tomadas hoje',
          color: AppTheme.primary,
          icon: Icons.check_circle,
        ),
        const SizedBox(width: 12),
        _SummaryCard(
          value: '${total - taken}',
          label: 'Pendentes',
          color: AppTheme.accent,
          icon: Icons.access_time,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _SummaryCard({
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
            const SizedBox(width: 12),
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

class _EmptyMeds extends StatelessWidget {
  const _EmptyMeds();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          const Icon(Icons.medication, size: 64, color: Color(0xFFBDBDBD)),
          const SizedBox(height: 12),
          const Text(
            'Nenhuma medicação cadastrada',
            style: TextStyle(fontSize: 18, color: AppTheme.textMedium),
          ),
          const SizedBox(height: 8),
          const Text(
            'Toque em + para adicionar',
            style: TextStyle(fontSize: 16, color: AppTheme.textMedium),
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home, size: 30), label: 'Início'),
        BottomNavigationBarItem(icon: Icon(Icons.medication, size: 30), label: 'Medicações'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications, size: 30), label: 'Alertas'),
        BottomNavigationBarItem(icon: Icon(Icons.qr_code, size: 30), label: 'QR Code'),
      ],
    );
  }
}
