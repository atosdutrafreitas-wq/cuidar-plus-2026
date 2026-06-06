import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'ocr_types.dart';

class OcrServiceImpl implements OcrServiceBase {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<OcrResult> extractFromXFile(XFile xfile) async {
    final inputImage = InputImage.fromFile(File(xfile.path));
    final recognized = await _textRecognizer.processImage(inputImage);
    return OcrResult(
      rawText: recognized.text,
      medications: _parseMedications(recognized.text),
    );
  }

  List<OcrMedication> _parseMedications(String text) {
    final results = <OcrMedication>[];
    final lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      final dosagePattern = RegExp(
          r'\b(\d+(\.\d+)?\s*(mg|ml|mcg|g|ui|cp|comp|cps|comprimido))\b',
          caseSensitive: false);

      if (dosagePattern.hasMatch(line) && line.length > 5) {
        final dosageMatch = dosagePattern.firstMatch(line);
        final nameEnd = dosageMatch?.start ?? line.length;
        final name = line.substring(0, nameEnd).trim();
        final dosage = dosageMatch?.group(0) ?? '';

        if (name.isNotEmpty) {
          final instructions =
              (i + 1 < lines.length) ? lines[i + 1].trim() : null;
          results.add(OcrMedication(
            name: _capitalize(name),
            dosage: dosage,
            instructions: instructions,
          ));
        }
      }
    }
    return results;
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  @override
  void dispose() => _textRecognizer.close();
}
