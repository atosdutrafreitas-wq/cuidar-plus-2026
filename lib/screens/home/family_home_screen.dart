import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/elderly_provider.dart';
import '../../providers/alert_provider.dart';

class FamilyHomeScreen extends ConsumerWidget {
  const FamilyHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(authNotifierProvider).valueOrNull;
    final familyId = profile?.familyId ?? profile?.id ?? '';
    final elderly = ref.watch(elderlyListProvider(familyId));
    final alerts = ref.watch(alertsProvider(familyId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Familiar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, size: 30),
            onPressed: () => context.push('/reports'),
          ),
          IconButton(
            icon: const Icon(Icons.person, size: 30),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              alerts.when(
                data: (list) {
                  final pending = list.where((a) => a.type.name == 'help').toList();
                  if (pending.isEmpty) return const SizedBox.shrink();
                  return _HelpAlertBanner(count: pending.length);
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              const Text('Idosos cadastrados',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              elderly.when(
                data: (list) => list.isEmpty
                    ? _AddElderlyCard(onTap: () => context.push('/register'))
                    : Column(
                        children: list
                            .map((e) => _ElderlyCard(
                                  name: e.name,
                                  age: e.age,
                                  onTap: () {
                                    ref
                                        .read(selectedElderlyIdProvider.notifier)
                                        .state = e.id;
                                    context.push('/medications');
                                  },
                                ))
                            .toList(),
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Erro: $e'),
              ),
              const SizedBox(height: 24),
              const Text('Acesso rápido',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _QuickCard(
                    icon: Icons.medication,
                    label: 'Medicações',
                    color: AppTheme.primary,
                    onTap: () => context.push('/medications'),
                  ),
                  _QuickCard(
                    icon: Icons.notifications,
                    label: 'Alertas',
                    color: AppTheme.accent,
                    onTap: () => context.push('/alerts'),
                  ),
                  _QuickCard(
                    icon: Icons.qr_code,
                    label: 'QR Médico',
                    color: Colors.blue,
                    onTap: () => context.push('/qr-code'),
                  ),
                  _QuickCard(
                    icon: Icons.bar_chart,
                    label: 'Relatórios',
                    color: Colors.purple,
                    onTap: () => context.push('/reports'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpAlertBanner extends StatelessWidget {
  final int count;
  const _HelpAlertBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.danger,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$count pedido(s) de ajuda pendente(s)!',
              style: const TextStyle(
                  fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/alerts'),
            child: const Text('Ver',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    decoration: TextDecoration.underline)),
          ),
        ],
      ),
    );
  }
}

class _ElderlyCard extends StatelessWidget {
  final String name;
  final int age;
  final VoidCallback onTap;

  const _ElderlyCard(
      {required this.name, required this.age, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: AppTheme.primary.withOpacity(0.1),
          child: const Icon(Icons.elderly, size: 35, color: AppTheme.primary),
        ),
        title: Text(name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        subtitle: Text('$age anos',
            style: const TextStyle(fontSize: 16, color: AppTheme.textMedium)),
        trailing: const Icon(Icons.chevron_right, size: 30, color: AppTheme.primary),
        onTap: onTap,
      ),
    );
  }
}

class _AddElderlyCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AddElderlyCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(
              color: AppTheme.primary, width: 2, style: BorderStyle.none),
          borderRadius: BorderRadius.circular(16),
          color: AppTheme.primary.withOpacity(0.05),
        ),
        child: Column(
          children: [
            const Icon(Icons.person_add, size: 48, color: AppTheme.primary),
            const SizedBox(height: 8),
            const Text('Cadastrar idoso',
                style: TextStyle(
                    fontSize: 18,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color)),
          ],
        ),
      ),
    );
  }
}
