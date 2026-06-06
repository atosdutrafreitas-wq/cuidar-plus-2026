import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme.dart';
import '../../services/ocr_service.dart';
import '../../widgets/big_button.dart';

class OcrReceiptScreen extends StatefulWidget {
  const OcrReceiptScreen({super.key});

  @override
  State<OcrReceiptScreen> createState() => _OcrReceiptScreenState();
}

class _OcrReceiptScreenState extends State<OcrReceiptScreen> {
  final _picker = ImagePicker();
  final _ocr = OcrService();
  XFile? _image;
  OcrResult? _result;
  bool _loading = false;

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 90);
    if (picked == null) return;

    setState(() {
      _image = picked;
      _loading = true;
      _result = null;
    });

    final result = await _ocr.extractFromXFile(picked);
    setState(() {
      _result = result;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _ocr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: const Text('Escanear Receita')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.smartphone, size: 80, color: AppTheme.primary),
                SizedBox(height: 24),
                Text(
                  'Disponível apenas no app mobile',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'A leitura de receitas por foto requer a câmera do celular.',
                  style: TextStyle(fontSize: 17, color: AppTheme.textMedium),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Escanear Receita')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fotografe a receita médica para cadastrar medicações automaticamente.',
                style: TextStyle(fontSize: 18, color: AppTheme.textMedium),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt, size: 28),
                      label: const Text('Câmera'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library, size: 28),
                      label: const Text('Galeria'),
                    ),
                  ),
                ],
              ),
              if (_image != null) ...[
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    _image!.path,
                    height: 200,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ],
              if (_loading) ...[
                const SizedBox(height: 30),
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 12),
                const Center(
                    child: Text('Analisando receita...',
                        style: TextStyle(fontSize: 18))),
              ],
              if (_result != null) ...[
                const SizedBox(height: 24),
                if (_result!.medications.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Não foi possível identificar medicações na receita. Tente uma foto mais nítida ou cadastre manualmente.',
                      style: TextStyle(fontSize: 17),
                    ),
                  )
                else ...[
                  Text(
                    '${_result!.medications.length} medicação(ões) encontrada(s):',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ..._result!.medications.map((m) => _OcrMedCard(med: m)),
                  const SizedBox(height: 24),
                  BigButton(
                    label: 'Cadastrar medicações encontradas',
                    icon: Icons.check_circle,
                    onPressed: () => context.push('/add-medication'),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OcrMedCard extends StatelessWidget {
  final OcrMedication med;
  const _OcrMedCard({required this.med});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading:
            const Icon(Icons.medication, color: AppTheme.primary, size: 28),
        title: Text(med.name,
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dosagem: ${med.dosage}',
                style: const TextStyle(fontSize: 16)),
            if (med.instructions != null)
              Text(med.instructions!,
                  style: const TextStyle(
                      fontSize: 14, color: AppTheme.textMedium)),
          ],
        ),
      ),
    );
  }
}
