import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/big_button.dart';

class VerifyOtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  const VerifyOtpScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  final _codeController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Digite o código de 6 dígitos',
                style: TextStyle(fontSize: 16))),
      );
      return;
    }

    setState(() => _loading = true);
    final ok = await ref.read(authNotifierProvider.notifier).verifyOtp(code);
    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      final profile = ref.read(authNotifierProvider).valueOrNull;
      if (profile == null) {
        context.go('/register');
      } else {
        context.go('/home');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Código inválido. Tente novamente.',
                style: TextStyle(fontSize: 16))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verificar código')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.message, size: 64, color: AppTheme.primary),
              const SizedBox(height: 20),
              const Text('Digite o código SMS',
                  style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                'Código enviado para ${widget.phoneNumber}',
                style: const TextStyle(
                    fontSize: 18, color: AppTheme.textMedium),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(
                    fontSize: 36,
                    letterSpacing: 12,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: '000000',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 40),
              BigButton(
                label: _loading ? 'Verificando...' : 'Confirmar',
                icon: Icons.check_circle,
                onPressed: _loading ? null : _verify,
                loading: _loading,
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: const Text(
                    'Reenviar código',
                    style: TextStyle(fontSize: 18, color: AppTheme.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
