import 'dart:io';
import '../models/document_type.dart';
import '../services/cloud_vision_service.dart';
import 'parsers/document_detector.dart';
import 'parsers/id_card_parser.dart';
import 'parsers/birth_certificate_parser.dart';
import 'parsers/driver_license_parser.dart'; // 🆕 Added

class OcrRepository {
  final CloudVisionService visionService;
  final DocumentDetector detector = DocumentDetector();

  // ✅ Initialize parsers
  final IdCardParser idParser = IdCardParser();
  final BirthCertificateParser birthParser = BirthCertificateParser();
  final DriverLicenseParser licenseParser = DriverLicenseParser(); // 🆕 Added

  OcrRepository({required this.visionService});

  Future<Map<String, dynamic>> scanDocument(File imageFile) async {
    // 1️⃣ Extract text from image using Google Vision API
    final ocrResult = await visionService.extractText(imageFile);
    final text = ocrResult.fullText ?? "";

    // 2️⃣ Detect document type using keywords
    final docType = detector.detect(text);
    print("🧠 Detected document type: $docType");

    // 3️⃣ Parse based on detected type
    switch (docType) {
      case DocumentType.nationalId:
        final parsed = idParser.parse(ocrResult);
        print("📄 Parsed National ID successfully");
        return {
          "type": docType,
          "data": parsed,
        };

      case DocumentType.birthCertificate:
        final parsed = birthParser.parse(ocrResult);
        print("📄 Parsed Birth Certificate successfully");
        return {
          "type": docType,
          "data": parsed,
        };

      case DocumentType.drivingLicense: // 🆕 Added
        final parsed = licenseParser.parse(ocrResult);
        print("📄 Parsed Driver License successfully");
        return {
          "type": docType,
          "data": parsed,
        };

      // 🧩 Other types can be added here later (passport, etc.)
      default:
        print("⚠️ Unknown or unsupported document type");
        return {
          "type": DocumentType.unknown,
          "data": null,
        };
    }
  }
}
