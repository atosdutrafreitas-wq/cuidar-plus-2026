import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/qr_profile_model.dart';
import '../../services/firestore_service.dart';

final _qrProfileProvider =
    FutureProvider.family<QrProfileModel?, String>((ref, elderlyId) async {
  return FirestoreService().getQrProfile(elderlyId);
});

class QrProfilePublicScreen extends ConsumerWidget {
  final String elderlyId;
  const QrProfilePublicScreen({super.key, required this.elderlyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(_qrProfileProvider(elderlyId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil Médico'),
        backgroundColor: AppTheme.danger,
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(
              child: Text('Perfil não encontrado',
                  style: TextStyle(fontSize: 20)),
            );
          }
          return _ProfileView(profile: profile);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  final QrProfileModel profile;
  const _ProfileView({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _EmergencyHeader(profile: profile),
          const SizedBox(height: 20),
          _InfoCard(
            title: 'Informações Pessoais',
            icon: Icons.person,
            children: [
              _InfoRow('Nome', profile.name),
              _InfoRow('Idade', '${profile.age} anos'),
              _InfoRow('Tipo sanguíneo', profile.bloodType),
              if (profile.address != null)
                _InfoRow('Endereço', profile.address!),
            ],
          ),
          const SizedBox(height: 16),
          if (profile.allergies.isNotEmpty)
            _InfoCard(
              title: 'Alergias',
              icon: Icons.warning,
              color: AppTheme.danger,
              children: profile.allergies
                  .map((a) => _InfoRow('', a, valueStyle: const TextStyle(
                      fontSize: 17, color: AppTheme.danger, fontWeight: FontWeight.bold)))
                  .toList(),
            ),
          if (profile.allergies.isNotEmpty) const SizedBox(height: 16),
          _InfoCard(
            title: 'Contato de Emergência',
            icon: Icons.phone,
            children: [
              _InfoRow('Nome', profile.emergencyContact),
              _InfoRow('Telefone', profile.emergencyPhone),
            ],
          ),
          if (profile.healthPlan != null) ...[
            const SizedBox(height: 16),
            _InfoCard(
              title: 'Convênio',
              icon: Icons.local_hospital,
              children: [
                _InfoRow('Convênio', profile.healthPlan!),
                if (profile.healthPlanCard != null)
                  _InfoRow('Carteirinha', profile.healthPlanCard!),
              ],
            ),
          ],
          const SizedBox(height: 16),
          _MedicationsCard(medications: profile.medications),
        ],
      ),
    );
  }
}

class _EmergencyHeader extends StatelessWidget {
  final QrProfileModel profile;
  const _EmergencyHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.danger,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.emergency, size: 40, color: Colors.white),
          const SizedBox(height: 8),
          const Text('FICHA DE EMERGÊNCIA',
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  letterSpacing: 2)),
          const SizedBox(height: 4),
          Text(profile.name,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Text('${profile.age} anos',
              style: const TextStyle(fontSize: 20, color: Colors.white70)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(profile.bloodType,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.danger)),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.icon,
    this.color = AppTheme.primary,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Text(title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color)),
              ],
            ),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _InfoRow(this.label, this.value, {this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            SizedBox(
              width: 120,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 15, color: AppTheme.textMedium)),
            ),
          ],
          Expanded(
            child: Text(value,
                style: valueStyle ??
                    const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _MedicationsCard extends StatelessWidget {
  final List<QrMedication> medications;
  const _MedicationsCard({required this.medications});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.medication, color: AppTheme.primary, size: 22),
                SizedBox(width: 8),
                Text('Medicações',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary)),
              ],
            ),
            const Divider(height: 16),
            if (medications.isEmpty)
              const Text('Nenhuma medicação registrada',
                  style: TextStyle(fontSize: 16, color: AppTheme.textMedium)),
            ...medications.map((m) => _MedTile(med: m)),
          ],
        ),
      ),
    );
  }
}

class _MedTile extends StatelessWidget {
  final QrMedication med;
  const _MedTile({required this.med});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${med.name} — ${med.dosage}',
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Horários: ${med.scheduledTimes.join(', ')}',
              style: const TextStyle(fontSize: 15)),
          if (med.lastTaken != null)
            Text(
              'Última tomada: ${DateFormat('dd/MM HH:mm').format(med.lastTaken!)}',
              style: const TextStyle(
                  fontSize: 14, color: AppTheme.textMedium),
            ),
        ],
      ),
    );
  }
}
