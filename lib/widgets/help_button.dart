import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/alert_provider.dart';
import '../providers/elderly_provider.dart';

class HelpButton extends ConsumerWidget {
  const HelpButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _onHelp(context, ref),
        icon: const Icon(Icons.sos, size: 32),
        label: const Text(
          'AJUDA',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.danger,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          shadowColor: AppTheme.danger.withOpacity(0.5),
        ),
      ),
    );
  }

  Future<void> _onHelp(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.danger,
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.white, size: 32),
            SizedBox(width: 12),
            Text('PEDIDO DE AJUDA',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
        ),
        content: const Text(
          'Você vai avisar seus familiares e cuidadores que precisa de ajuda.\n\nDeseja continuar?',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white70, fontSize: 18)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.danger,
            ),
            child: const Text('SIM, PRECISO DE AJUDA',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final profile = ref.read(authNotifierProvider).valueOrNull;
    final elderlyId = ref.read(selectedElderlyIdProvider) ?? profile?.id ?? '';
    final familyId = profile?.familyId ?? profile?.id ?? '';

    await ref.read(alertNotifierProvider.notifier).sendHelp(
          elderlyId: elderlyId,
          familyId: familyId,
          elderlyName: profile?.name ?? 'Idoso',
        );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pedido de ajuda enviado aos seus familiares!',
              style: TextStyle(fontSize: 16)),
          backgroundColor: AppTheme.danger,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }
}
