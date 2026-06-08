import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/big_button.dart';
import '../legal/privacy_policy_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _keyController = TextEditingController();
  String _selectedRole = AppConstants.roleElderly;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _acceptedPrivacyPolicy = false;

  final _roles = [
    {'value': AppConstants.roleElderly, 'label': 'Sou o idoso', 'icon': Icons.elderly},
    {'value': AppConstants.roleFamiliar, 'label': 'Sou familiar', 'icon': Icons.family_restroom},
    {'value': AppConstants.roleCaregiver, 'label': 'Sou cuidador(a)', 'icon': Icons.medical_services},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final inviteKey = _keyController.text.trim().toUpperCase();

    if (name.isEmpty) {
      _showError('Digite seu nome completo');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _showError('Digite um e-mail válido');
      return;
    }
    if (password.length < 6) {
      _showError('A senha deve ter pelo menos 6 caracteres');
      return;
    }
    if (inviteKey.isEmpty) {
      _showError('Digite a chave de convite que você recebeu');
      return;
    }
    if (!_acceptedPrivacyPolicy) {
      _showError('Para continuar, você precisa ler e aceitar a Política de Privacidade');
      return;
    }

    setState(() => _loading = true);
    final notifier = ref.read(authNotifierProvider.notifier);
    try {
      await notifier.signUp(email: email, password: password);
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw Exception('Não foi possível criar sua conta. Tente novamente.');
      }
      await notifier.createProfileWithInviteKey(
        uid: uid,
        email: email,
        name: name,
        role: _selectedRole,
        inviteKeyCode: inviteKey,
        consentVersion: AppConstants.privacyPolicyVersion,
      );
      if (mounted) context.go('/home');
    } on FirebaseAuthException catch (e) {
      await _abortSignUp();
      if (!mounted) return;
      _showError(_friendlyAuthError(e));
    } catch (e) {
      await _abortSignUp();
      if (!mounted) return;
      _showError('Não foi possível criar sua conta: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Se o cadastro do perfil falhar (ex: chave inválida) depois da conta de
  /// autenticação já ter sido criada, desfaz a conta para permitir nova tentativa.
  Future<void> _abortSignUp() async {
    try {
      await FirebaseAuth.instance.currentUser?.delete();
    } catch (_) {
      await FirebaseAuth.instance.signOut();
    }
  }

  String _friendlyAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado. Tente entrar na tela de login.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'weak-password':
        return 'Senha muito fraca. Use pelo menos 6 caracteres.';
      default:
        return error.message ?? 'Não foi possível criar sua conta.';
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, style: const TextStyle(fontSize: 16))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Chave de convite',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text(
                'Pergunte ao responsável pela família o código que ele recebeu',
                style: TextStyle(fontSize: 15, color: AppTheme.textMedium),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _keyController,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(fontSize: 22, letterSpacing: 2),
                decoration: const InputDecoration(
                  hintText: 'Ex: ABC123XY',
                  prefixIcon: Icon(Icons.vpn_key, size: 28),
                ),
              ),
              const SizedBox(height: 32),
              const Text('Seu nome completo',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(fontSize: 22),
                decoration: const InputDecoration(
                  hintText: 'Ex: Maria da Silva',
                  prefixIcon: Icon(Icons.person, size: 28),
                ),
              ),
              const SizedBox(height: 32),
              const Text('E-mail',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
              const SizedBox(height: 32),
              const Text('Crie uma senha',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(fontSize: 22),
                decoration: InputDecoration(
                  hintText: 'Pelo menos 6 caracteres',
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
              const SizedBox(height: 36),
              const Text('Quem é você?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ..._roles.map((role) => _RoleTile(
                    icon: role['icon'] as IconData,
                    label: role['label'] as String,
                    selected: _selectedRole == role['value'],
                    onTap: () =>
                        setState(() => _selectedRole = role['value'] as String),
                  )),
              const SizedBox(height: 28),
              InkWell(
                onTap: () => setState(() => _acceptedPrivacyPolicy = !_acceptedPrivacyPolicy),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _acceptedPrivacyPolicy,
                        onChanged: (v) =>
                            setState(() => _acceptedPrivacyPolicy = v ?? false),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 16, color: AppTheme.textDark),
                              children: [
                                const TextSpan(text: 'Li e aceito a '),
                                TextSpan(
                                  text: 'Política de Privacidade',
                                  style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => const PrivacyPolicyScreen(),
                                          ),
                                        ),
                                ),
                                const TextSpan(
                                    text: ', incluindo a coleta de dados de saúde para uso do app.'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              BigButton(
                label: _loading ? 'Salvando...' : 'Entrar no Cuidar+',
                icon: Icons.favorite,
                onPressed: _loading ? null : _save,
                loading: _loading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppTheme.primary : const Color(0xFFBDBDBD),
            width: 2,
          ),
          boxShadow: selected
              ? [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 8)]
              : [],
        ),
        child: Row(
          children: [
            Icon(icon, size: 36, color: selected ? Colors.white : AppTheme.primary),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : AppTheme.textDark,
              ),
            ),
            const Spacer(),
            if (selected)
              const Icon(Icons.check_circle, color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }
}
