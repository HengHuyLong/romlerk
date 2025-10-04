import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/ocr_result_model.dart';

class CloudVisionService {
  final String apiKey;
  CloudVisionService(this.apiKey);

  Future<OcrResult> extractText(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final url = Uri.parse(
      "https://vision.googleapis.com/v1/images:annotate?key=$apiKey",
    );

    final body = jsonEncode({
      "requests": [
        {
          "image": {"content": base64Image},
          "features": [
            {"type": "DOCUMENT_TEXT_DETECTION"}
          ],
          "imageContext": {
            // Tell Vision API to expect Khmer + English
            "languageHints": ["km", "en"]
          }
        }
      ]
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return OcrResult.fromJson(json);
    } else {
      throw Exception("Vision API failed: ${response.body}");
    }
  }
}
