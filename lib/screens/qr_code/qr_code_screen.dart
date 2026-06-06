import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/elderly_provider.dart';

class QrCodeScreen extends ConsumerWidget {
  const QrCodeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(authNotifierProvider).valueOrNull;
    final elderlyId = ref.watch(selectedElderlyIdProvider) ?? profile?.id ?? '';

    // QR URL aponta para perfil público
    final qrUrl =
        'https://cuidarplus.web.app/qr-profile/$elderlyId';

    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Médico')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              const Text(
                'QR Code Médico',
                style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Mostre este código para médicos e socorristas.\nEle abre uma página com todos os dados de saúde.',
                style: TextStyle(fontSize: 18, color: AppTheme.textMedium),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: qrUrl,
                  version: QrVersions.auto,
                  size: 260,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppTheme.primary,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.security, color: AppTheme.primary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Seus dados são protegidos. Somente informações de emergência são exibidas.',
                        style: TextStyle(
                            fontSize: 15, color: AppTheme.textMedium),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Dados que aparecem ao escanear:',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _DataItem(icon: Icons.person, label: 'Nome, idade e foto'),
              _DataItem(icon: Icons.bloodtype, label: 'Tipo sanguíneo e alergias'),
              _DataItem(icon: Icons.local_hospital, label: 'Convênio e carteirinha'),
              _DataItem(icon: Icons.phone, label: 'Contato de emergência'),
              _DataItem(icon: Icons.medication, label: 'Medicações e horários'),
              _DataItem(icon: Icons.location_on, label: 'Endereço'),
            ],
          ),
        ),
      ),
    );
  }
}

class _DataItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DataItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 24),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 17)),
        ],
      ),
    );
  }
}
