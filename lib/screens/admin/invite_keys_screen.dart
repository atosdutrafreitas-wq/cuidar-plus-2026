import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../models/invite_key_model.dart';
import '../../providers/invite_key_provider.dart';

class InviteKeysScreen extends ConsumerWidget {
  const InviteKeysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keysAsync = ref.watch(inviteKeysStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Chaves de convite')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateFamilyKeyDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nova família'),
      ),
      body: keysAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Não foi possível carregar as chaves: $e',
                style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
          ),
        ),
        data: (keys) {
          if (keys.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Nenhuma chave criada ainda.\nToque em "Nova família" para começar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: AppTheme.textMedium),
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: keys.length,
            itemBuilder: (context, i) => _KeyCard(
              keyModel: keys[i],
              onToggleActive: () => ref
                  .read(inviteKeyRepositoryProvider)
                  .setActive(keys[i].code, !keys[i].active),
              onCreateExtra: keys[i].familyId == null
                  ? null
                  : () => _showCreateExtraKeyDialog(context, ref, keys[i]),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showCreateFamilyKeyDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final maxUsesController = TextEditingController(text: '4');
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Criar chave para nova família'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome da família'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: maxUsesController,
              decoration: const InputDecoration(labelText: 'Quantos podem se cadastrar com esta chave'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Criar')),
        ],
      ),
    );

    if (result != true || !context.mounted) return;
    final name = nameController.text.trim();
    final maxUses = int.tryParse(maxUsesController.text.trim()) ?? 0;
    if (name.isEmpty || maxUses <= 0) return;

    try {
      final code = await ref.read(inviteKeyRepositoryProvider).createFamilyWithKey(
            familyName: name,
            maxUses: maxUses,
          );
      if (context.mounted) _showCodeDialog(context, code, name);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar chave: $e')),
        );
      }
    }
  }

  Future<void> _showCreateExtraKeyDialog(
      BuildContext context, WidgetRef ref, InviteKeyModel base) async {
    final maxUsesController = TextEditingController(text: '1');
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Chave extra para "${base.familyName}"'),
        content: TextField(
          controller: maxUsesController,
          decoration: const InputDecoration(labelText: 'Quantos podem se cadastrar com esta chave'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Criar')),
        ],
      ),
    );

    if (result != true || !context.mounted) return;
    final maxUses = int.tryParse(maxUsesController.text.trim()) ?? 0;
    if (maxUses <= 0) return;

    try {
      final code = await ref.read(inviteKeyRepositoryProvider).createExtraKey(
            familyId: base.familyId!,
            familyName: base.familyName,
            maxUses: maxUses,
          );
      if (context.mounted) _showCodeDialog(context, code, base.familyName);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar chave: $e')),
        );
      }
    }
  }

  void _showCodeDialog(BuildContext context, String code, String familyName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chave criada!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Família: $familyName', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            SelectableText(
              code,
              style: const TextStyle(
                  fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4, color: AppTheme.primary),
            ),
            const SizedBox(height: 8),
            const Text('Compartilhe esse código com a família para que possam se cadastrar.',
                style: TextStyle(fontSize: 14, color: AppTheme.textMedium)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('Código copiado!')),
              );
            },
            child: const Text('Copiar'),
          ),
          ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fechar')),
        ],
      ),
    );
  }
}

class _KeyCard extends StatelessWidget {
  final InviteKeyModel keyModel;
  final VoidCallback onToggleActive;
  final VoidCallback? onCreateExtra;

  const _KeyCard({required this.keyModel, required this.onToggleActive, this.onCreateExtra});

  @override
  Widget build(BuildContext context) {
    final available = keyModel.isAvailable;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(keyModel.familyName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Switch(value: keyModel.active, onChanged: (_) => onToggleActive()),
              ],
            ),
            const SizedBox(height: 4),
            SelectableText(
              keyModel.code,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 3, color: AppTheme.primary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  available ? Icons.check_circle : Icons.cancel,
                  size: 18,
                  color: available ? AppTheme.primary : AppTheme.danger,
                ),
                const SizedBox(width: 6),
                Text(
                  '${keyModel.usedCount} de ${keyModel.maxUses} usados'
                  '${keyModel.active ? '' : ' • desativada'}',
                  style: const TextStyle(fontSize: 15, color: AppTheme.textMedium),
                ),
              ],
            ),
            if (onCreateExtra != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: onCreateExtra,
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  label: const Text('Criar chave extra'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
