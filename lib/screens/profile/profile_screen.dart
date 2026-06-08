import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
              Text(profile?.email ?? '',
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
              if (profile?.role == 'admin')
                _MenuItem(
                  icon: Icons.vpn_key,
                  label: 'Chaves de convite (admin)',
                  onTap: () => context.push('/admin/keys'),
                ),
              const SizedBox(height: 12),
              const Text('Privacidade e dados (LGPD)',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textMedium)),
              const SizedBox(height: 12),
              _MenuItem(
                icon: Icons.privacy_tip,
                label: 'Política de Privacidade',
                onTap: () => context.push('/privacy-policy'),
              ),
              _MenuItem(
                icon: Icons.download,
                label: 'Meus dados (visualizar/exportar)',
                onTap: () => _showExportDataDialog(context, ref),
              ),
              _MenuItem(
                icon: Icons.delete_forever,
                label: 'Excluir minha conta e meus dados',
                onTap: () => _showDeleteAccountDialog(context, ref),
              ),
              const SizedBox(height: 24),
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

/// LGPD (direito de acesso/portabilidade): mostra os dados pessoais do
/// usuário e permite copiá-los como JSON.
Future<void> _showExportDataDialog(BuildContext context, WidgetRef ref) async {
  showDialog(
    context: context,
    builder: (ctx) => FutureBuilder<Map<String, dynamic>>(
      future: ref.read(authNotifierProvider.notifier).exportUserData(),
      builder: (ctx, snapshot) {
        Widget content;
        String? json;
        if (snapshot.connectionState == ConnectionState.waiting) {
          content = const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          content = Text('Não foi possível carregar seus dados: ${snapshot.error}',
              style: const TextStyle(fontSize: 16));
        } else {
          json = const JsonEncoder.withIndent('  ').convert(snapshot.data);
          content = SingleChildScrollView(
            child: SelectableText(json,
                style: const TextStyle(fontSize: 14, fontFamily: 'monospace')),
          );
        }
        return AlertDialog(
          title: const Text('Meus dados'),
          content: SizedBox(width: 400, child: content),
          actions: [
            if (json != null)
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: json!));
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Dados copiados!')),
                  );
                },
                child: const Text('Copiar'),
              ),
            ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fechar')),
          ],
        );
      },
    ),
  );
}

/// LGPD (direito de eliminação): confirma, reautentica e exclui a conta.
Future<void> _showDeleteAccountDialog(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Excluir minha conta?'),
      content: const Text(
        'Isso vai apagar seu perfil e sua conta de acesso permanentemente. '
        'Essa ação não pode ser desfeita. Deseja continuar?',
        style: TextStyle(fontSize: 16),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Excluir'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  final passwordController = TextEditingController();
  final password = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Confirme sua senha'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Por segurança, digite sua senha para confirmar a exclusão.',
              style: TextStyle(fontSize: 15, color: AppTheme.textMedium)),
          const SizedBox(height: 12),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Senha'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
          onPressed: () => Navigator.pop(ctx, passwordController.text),
          child: const Text('Confirmar exclusão'),
        ),
      ],
    ),
  );
  if (password == null || password.isEmpty || !context.mounted) return;

  try {
    await ref.read(authNotifierProvider.notifier).reauthenticate(password);
    await ref.read(authNotifierProvider.notifier).deleteAccount();
    if (context.mounted) context.go('/login');
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível excluir a conta: $e')),
      );
    }
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
      case 'admin':
        return 'Administrador';
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
