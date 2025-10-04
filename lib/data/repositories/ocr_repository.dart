import 'dart:io';
import '../models/document_type.dart';
import '../services/cloud_vision_service.dart';
import 'parsers/document_detector.dart';
import 'parsers/id_card_parser.dart';

class OcrRepository {
  final CloudVisionService visionService;
  final DocumentDetector detector = DocumentDetector();
  final IdCardParser idParser = IdCardParser();

  OcrRepository({required this.visionService});

  Future<Map<String, dynamic>> scanDocument(File imageFile) async {
    // 1. Call Google Vision OCR
    final ocrResult = await visionService.extractText(imageFile);
    final text = ocrResult.fullText ?? "";

    // 2. Detect document type
    final docType = detector.detect(text);

    // 3. Parse depending on type
    switch (docType) {
      case DocumentType.nationalId:
        final parsed = idParser.parse(ocrResult);
        return {
          "type": docType,
          "data": parsed, // structured model
        };

      // 4. Any unsupported type
      default:
        return {
          "type": DocumentType.unknown,
          "data": null, // no raw text anymore
        };
    }
  }
}
