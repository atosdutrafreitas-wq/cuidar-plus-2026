import 'package:firebase_auth/firebase_auth.dart';
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || !email.contains('@')) {
      _showError('Digite um e-mail válido');
      return;
    }
    if (password.isEmpty) {
      _showError('Digite sua senha');
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(authNotifierProvider.notifier).signIn(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showError(_friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
      case 'invalid-credential':
      case 'wrong-password':
        return 'E-mail ou senha incorretos.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-disabled':
        return 'Esta conta foi desativada. Avise o suporte.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';
      default:
        return error.message ?? 'Não foi possível entrar. Tente novamente.';
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
              const Text('E-mail',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 22),
                decoration: const InputDecoration(
                  hintText: 'seuemail@exemplo.com',
                  prefixIcon: Icon(Icons.email, size: 28),
                ),
              ),
              const SizedBox(height: 28),
              const Text('Senha',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(fontSize: 22),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock, size: 28),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      size: 26,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              BigButton(
                label: _loading ? 'Entrando...' : 'Entrar',
                icon: Icons.login,
                onPressed: _loading ? null : _signIn,
                loading: _loading,
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => context.push('/register'),
                  child: const Text(
                    'Tenho uma chave de convite — criar conta',
                    style: TextStyle(fontSize: 17, color: AppTheme.primary),
                  ),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () => context.push('/privacy-policy'),
                  child: const Text(
                    'Política de Privacidade',
                    style: TextStyle(fontSize: 15, color: AppTheme.textMedium),
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
