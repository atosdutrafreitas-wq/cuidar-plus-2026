import 'package:image_picker/image_picker.dart';

abstract class OcrServiceBase {
  Future<OcrResult> extractFromXFile(XFile xfile);
  void dispose();
}

class OcrResult {
  final String rawText;
  final List<OcrMedication> medications;
  OcrResult({required this.rawText, required this.medications});
}

class OcrMedication {
  final String name;
  final String dosage;
  final String? instructions;
  OcrMedication({
    required this.name,
    required this.dosage,
    this.instructions,
  });
}
