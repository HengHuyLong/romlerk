import '../../models/ocr_result_model.dart';
import '../../models/national_id_model.dart';

class IdCardParser {
  NationalId parse(OcrResult result) {
    final text = result.fullText ?? "";
    final lines = text
        .split(RegExp(r'\n+'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // ===== Common regex patterns =====
    final idRegex = RegExp(r'\d{9,12}');
    final dateRegex = RegExp(r'(\d{2}[/-]\d{2}[/-]\d{4})');
    final genderRegex =
        RegExp(r'(M|F|ប្រុស|ស្រី|បុ\.?ស\.?|ស\.រ\.?)', caseSensitive: false);
    final heightRegex = RegExp(
      r'(?:(?:Height|កម្ពស់)[:\s]*)(\d{2,3})\s?(?:cm|ស\.ម\.?)?',
      caseSensitive: false,
    );
    final mrzRegex = RegExp(r'^[A-Z0-9<]{20,}$');

    // ===== Extract common fields =====
    final idNumber = idRegex.firstMatch(text)?.group(0);
    final dates = dateRegex.allMatches(text).map((m) => m.group(0)).toList();
    String? gender = genderRegex.firstMatch(text)?.group(0);
    final height = heightRegex.firstMatch(text)?.group(1);
    final mrzLines = lines.where((l) => mrzRegex.hasMatch(l)).toList();

    // ===== Normalize gender =====
    gender = _normalizeGender(gender);

    // ===== Extract names =====
    String? nameKh, nameEn;
    for (var line in lines) {
      if (RegExp(r'^[\u1780-\u17FF ]+$').hasMatch(line)) {
        nameKh ??= line;
      } else if (RegExp(r'^[A-Z ]+$').hasMatch(line)) {
        nameEn ??= line;
      }
    }

    // ===== Khmer text blocks for place of birth and address =====
    final khmerBlocks =
        lines.where((l) => RegExp(r'[\u1780-\u17FF]').hasMatch(l)).toList();

    String? placeOfBirth;
    String? address;

    if (khmerBlocks.isNotEmpty) {
      placeOfBirth = khmerBlocks.first;
      if (khmerBlocks.length > 1) {
        address =
            khmerBlocks.skip(1).reduce((a, b) => a.length > b.length ? a : b);
      }
    }

    // ===== Clean up height =====
    String? normalizedHeight;
    if (height != null && height.isNotEmpty) {
      normalizedHeight = height.replaceAll(RegExp(r'[^0-9]'), '');
      if (normalizedHeight.isEmpty) normalizedHeight = null;
    }

    // ===== Return NationalId =====
    return NationalId(
      idNumber: idNumber,
      nameKh: nameKh,
      nameEn: nameEn,
      dateOfBirth: dates.isNotEmpty ? dates.first : null,
      issuedDate: dates.length > 1 ? dates[1] : null,
      expiryDate: dates.length > 2 ? dates[2] : null,
      gender: gender,
      height: normalizedHeight,
      placeOfBirth: placeOfBirth,
      address: address,
      mrz1: mrzLines.isNotEmpty ? mrzLines[0] : null,
      mrz2: mrzLines.length > 1 ? mrzLines[1] : null,
      mrz3: mrzLines.length > 2 ? mrzLines[2] : null,
    );
  }

  // ✅ Helper to clean and normalize gender
  String? _normalizeGender(String? raw) {
    if (raw == null) return null;
    var g = raw.trim().replaceAll(RegExp(r'[^\u1780-\u17FFa-zA-Z]+'), '');
    if (RegExp(r'^(M|MALE|ប្រុស|បុរស|បុស|បុសស)$', caseSensitive: false)
        .hasMatch(g)) {
      return "ប្រុស";
    }
    if (RegExp(r'^(F|FEMALE|ស្រី|សរ)$', caseSensitive: false).hasMatch(g)) {
      return "ស្រី";
    }
    return null;
  }
}
