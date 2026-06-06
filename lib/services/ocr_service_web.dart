import 'package:image_picker/image_picker.dart';
import 'ocr_types.dart';

class OcrServiceImpl implements OcrServiceBase {
  @override
  Future<OcrResult> extractFromXFile(XFile xfile) async =>
      OcrResult(rawText: '', medications: []);

  @override
  void dispose() {}
}
