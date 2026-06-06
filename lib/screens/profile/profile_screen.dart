import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/big_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(authNotifierProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 56,
                backgroundColor: AppTheme.primary.withOpacity(0.15),
                backgroundImage: profile?.photoUrl != null
                    ? NetworkImage(profile!.photoUrl!)
                    : null,
                child: profile?.photoUrl == null
                    ? const Icon(Icons.person, size: 60, color: AppTheme.primary)
                    : null,
              ),
              const SizedBox(height: 16),
              Text(profile?.name ?? 'Usuário',
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(profile?.phone ?? '',
                  style: const TextStyle(
                      fontSize: 18, color: AppTheme.textMedium)),
              const SizedBox(height: 4),
              _RoleChip(role: profile?.role ?? 'familiar'),
              const SizedBox(height: 36),
              _MenuItem(
                icon: Icons.elderly,
                label: 'Idosos cadastrados',
                onTap: () => context.push('/family-home'),
              ),
              _MenuItem(
                icon: Icons.medication,
                label: 'Medicações',
                onTap: () => context.push('/medications'),
              ),
              _MenuItem(
                icon: Icons.bar_chart,
                label: 'Relatórios',
                onTap: () => context.push('/reports'),
              ),
              _MenuItem(
                icon: Icons.qr_code,
                label: 'QR Code Médico',
                onTap: () => context.push('/qr-code'),
              ),
              _MenuItem(
                icon: Icons.notifications_active,
                label: 'Alertas',
                onTap: () => context.push('/alerts'),
              ),
              const SizedBox(height: 32),
              BigButton(
                label: 'Sair da conta',
                icon: Icons.logout,
                backgroundColor: AppTheme.danger,
                onPressed: () async {
                  await ref.read(authNotifierProvider.notifier).signOut();
                  if (context.mounted) context.go('/login');
                },
              ),
              const SizedBox(height: 16),
              Text('Cuidar+ v1.0.0',
                  style: const TextStyle(
                      fontSize: 14, color: AppTheme.textMedium)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String role;
  const _RoleChip({required this.role});

  String get _label {
    switch (role) {
      case 'elderly':
        return 'Idoso';
      case 'familiar':
        return 'Familiar';
      case 'caregiver':
        return 'Cuidador(a)';
      default:
        return 'Usuário';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(_label,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary)),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(icon, color: AppTheme.primary, size: 28),
        title: Text(label,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right,
            color: AppTheme.textMedium, size: 28),
        onTap: onTap,
      ),
    );
  }
}
