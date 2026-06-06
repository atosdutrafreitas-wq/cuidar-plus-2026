import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/big_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  String _selectedRole = AppConstants.roleElderly;
  bool _loading = false;

  final _roles = [
    {'value': AppConstants.roleElderly, 'label': 'Sou o idoso', 'icon': Icons.elderly},
    {'value': AppConstants.roleFamiliar, 'label': 'Sou familiar', 'icon': Icons.family_restroom},
    {'value': AppConstants.roleCaregiver, 'label': 'Sou cuidador(a)', 'icon': Icons.medical_services},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite seu nome completo', style: TextStyle(fontSize: 16))),
      );
      return;
    }
    setState(() => _loading = true);
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final phone = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';
    await ref.read(authNotifierProvider.notifier).createProfile(
          uid: uid,
          phone: phone,
          name: name,
          role: _selectedRole,
        );
    if (mounted) context.go('/home');
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
              const SizedBox(height: 40),
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
