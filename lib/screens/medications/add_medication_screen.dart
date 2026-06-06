import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/medication_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/elderly_provider.dart';
import '../../providers/medication_provider.dart';
import '../../widgets/big_button.dart';

class AddMedicationScreen extends ConsumerStatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  ConsumerState<AddMedicationScreen> createState() =>
      _AddMedicationScreenState();
}

class _AddMedicationScreenState extends ConsumerState<AddMedicationScreen> {
  final _nameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _instructionsCtrl = TextEditingController();
  String _frequency = AppConstants.frequencies[0];
  final List<TimeOfDay> _times = [const TimeOfDay(hour: 8, minute: 0)];
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
    _instructionsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _times[index],
      helpText: 'Horário da medicação',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _times[index] = picked);
    }
  }

  Future<void> _pickDate({bool isEnd = false}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isEnd ? (_endDate ?? now.add(const Duration(days: 30))) : _startDate,
      firstDate: isEnd ? _startDate : now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() {
        if (isEnd) {
          _endDate = picked;
        } else {
          _startDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _showError('Digite o nome do medicamento');
      return;
    }
    if (_dosageCtrl.text.trim().isEmpty) {
      _showError('Digite a dosagem');
      return;
    }

    setState(() => _loading = true);

    final profile = ref.read(authNotifierProvider).valueOrNull;
    final elderlyId =
        ref.read(selectedElderlyIdProvider) ?? profile?.id ?? '';
    final familyId = profile?.familyId ?? profile?.id ?? '';

    final times = _times
        .map((t) =>
            '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')
        .toList();

    final med = MedicationModel(
      id: const Uuid().v4(),
      elderlyId: elderlyId,
      familyId: familyId,
      name: _nameCtrl.text.trim(),
      dosage: _dosageCtrl.text.trim(),
      frequency: _frequency,
      scheduledTimes: times,
      startDate: _startDate,
      endDate: _endDate,
      instructions: _instructionsCtrl.text.trim().isEmpty
          ? null
          : _instructionsCtrl.text.trim(),
      alertConfig: const AlertConfig(),
      createdAt: DateTime.now(),
    );

    await ref.read(medicationNotifierProvider.notifier).add(med, 'Paciente');

    if (mounted) {
      setState(() => _loading = false);
      context.pop();
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg, style: const TextStyle(fontSize: 16))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Medicação')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Nome do medicamento *'),
              TextField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(fontSize: 20),
                decoration: const InputDecoration(
                  hintText: 'Ex: Losartana',
                  prefixIcon: Icon(Icons.medication, size: 28),
                ),
              ),
              const SizedBox(height: 20),
              _label('Dosagem *'),
              TextField(
                controller: _dosageCtrl,
                style: const TextStyle(fontSize: 20),
                decoration: const InputDecoration(
                  hintText: 'Ex: 50mg, 1 comprimido',
                  prefixIcon: Icon(Icons.scale, size: 28),
                ),
              ),
              const SizedBox(height: 20),
              _label('Frequência'),
              DropdownButtonFormField<String>(
                value: _frequency,
                style: const TextStyle(
                    fontSize: 18, color: AppTheme.textDark),
                decoration: const InputDecoration(),
                items: AppConstants.frequencies
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (v) => setState(() => _frequency = v ?? _frequency),
              ),
              const SizedBox(height: 20),
              _label('Horários'),
              ..._times.asMap().entries.map((e) => _TimeTile(
                    index: e.key,
                    time: e.value,
                    onTap: () => _pickTime(e.key),
                    onRemove: _times.length > 1
                        ? () => setState(() => _times.removeAt(e.key))
                        : null,
                  )),
              TextButton.icon(
                onPressed: () => setState(
                    () => _times.add(const TimeOfDay(hour: 20, minute: 0))),
                icon: const Icon(Icons.add_circle, color: AppTheme.primary),
                label: const Text('Adicionar horário',
                    style: TextStyle(fontSize: 16, color: AppTheme.primary)),
              ),
              const SizedBox(height: 20),
              _label('Data de início'),
              _DateTile(
                date: _startDate,
                onTap: () => _pickDate(),
              ),
              const SizedBox(height: 12),
              _label('Data de término (opcional)'),
              _DateTile(
                date: _endDate,
                placeholder: 'Sem data de término',
                onTap: () => _pickDate(isEnd: true),
              ),
              const SizedBox(height: 20),
              _label('Instruções (opcional)'),
              TextField(
                controller: _instructionsCtrl,
                maxLines: 3,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  hintText: 'Ex: Tomar com água, após o almoço',
                ),
              ),
              const SizedBox(height: 40),
              BigButton(
                label: _loading ? 'Salvando...' : 'Salvar medicação',
                icon: Icons.save,
                onPressed: _loading ? null : _save,
                loading: _loading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      );
}

class _TimeTile extends StatelessWidget {
  final int index;
  final TimeOfDay time;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const _TimeTile({
    required this.index,
    required this.time,
    required this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final label =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.access_time, color: AppTheme.primary, size: 28),
      title: Text(label,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      subtitle: Text('Horário ${index + 1}',
          style: const TextStyle(fontSize: 15)),
      trailing: onRemove != null
          ? IconButton(
              icon: const Icon(Icons.remove_circle, color: AppTheme.danger),
              onPressed: onRemove,
            )
          : null,
      onTap: onTap,
    );
  }
}

class _DateTile extends StatelessWidget {
  final DateTime? date;
  final String placeholder;
  final VoidCallback onTap;

  const _DateTile({
    this.date,
    this.placeholder = '',
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = date != null
        ? '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}'
        : placeholder;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFBDBDBD)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppTheme.primary, size: 26),
            const SizedBox(width: 16),
            Text(label,
                style: TextStyle(
                    fontSize: 18,
                    color: date != null
                        ? AppTheme.textDark
                        : AppTheme.textMedium)),
            const Spacer(),
            const Icon(Icons.edit, size: 20, color: AppTheme.textMedium),
          ],
        ),
      ),
    );
  }
}
