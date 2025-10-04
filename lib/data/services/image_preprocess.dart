import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Simple, safe preprocess:
/// - Downscale if width/height > 2000px
/// - Compress to JPEG quality ~85
/// Returns a new temp file (doesn't overwrite the original).
class ImagePreprocess {
  static const int _maxDim = 2000; // keep large enough for OCR
  static const int _jpgQuality = 85;

  static Future<File> preprocess(File file) async {
    final originalBytes = await file.readAsBytes();

    // Decode
    final decoded = img.decodeImage(originalBytes);
    if (decoded == null) {
      // If decode fails, return the original file to avoid blocking flow
      return file;
    }

    // Downscale if needed
    img.Image output = decoded;
    final w = decoded.width, h = decoded.height;
    if (w > _maxDim || h > _maxDim) {
      final scale =
          (w > h) ? _maxDim / w : _maxDim / h; // maintain aspect ratio
      final targetW = (w * scale).round();
      final targetH = (h * scale).round();
      output = img.copyResize(decoded, width: targetW, height: targetH);
    }

    // Encode JPEG
    final compressed = img.encodeJpg(output, quality: _jpgQuality);

    // Write to temp
    final tmpDir = await getTemporaryDirectory();
    final outPath =
        '${tmpDir.path}/romlerk_pre_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final outFile = File(outPath);
    await outFile.writeAsBytes(compressed, flush: true);
    return outFile;
  }
}
