import 'package:image_picker/image_picker.dart';
import 'ocr_service_web.dart' if (dart.library.io) 'ocr_service_impl.dart';
import 'ocr_types.dart';

export 'ocr_types.dart';

class OcrService implements OcrServiceBase {
  final OcrServiceBase _impl = OcrServiceImpl();

  @override
  Future<OcrResult> extractFromXFile(XFile xfile) =>
      _impl.extractFromXFile(xfile);

  @override
  void dispose() => _impl.dispose();
}
