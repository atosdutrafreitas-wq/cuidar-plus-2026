import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/big_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      _showError('Digite um número de telefone válido');
      return;
    }
    setState(() => _loading = true);
    String formatted = phone;
    if (!phone.startsWith('+')) {
      formatted = '+55$phone';
    }
    await ref.read(authNotifierProvider.notifier).sendOtp(formatted);
    if (mounted) {
      setState(() => _loading = false);
      context.push('/verify-otp', extra: formatted);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg, style: const TextStyle(fontSize: 16))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(Icons.favorite,
                          size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    const Text('Cuidar+',
                        style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary)),
                    const SizedBox(height: 8),
                    const Text('Bem-vindo de volta!',
                        style:
                            TextStyle(fontSize: 20, color: AppTheme.textMedium)),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              const Text('Número de telefone',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 22),
                decoration: const InputDecoration(
                  hintText: '(51) 99999-9999',
                  prefixIcon: Icon(Icons.phone, size: 28),
                  prefixText: '+55 ',
                  prefixStyle: TextStyle(fontSize: 20, color: AppTheme.primary),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Você receberá um código SMS para confirmar',
                style: TextStyle(fontSize: 16, color: AppTheme.textMedium),
              ),
              const SizedBox(height: 40),
              BigButton(
                label: _loading ? 'Enviando...' : 'Receber código SMS',
                icon: Icons.sms,
                onPressed: _loading ? null : _sendOtp,
                loading: _loading,
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => context.push('/register'),
                  child: const Text(
                    'Criar nova conta',
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
