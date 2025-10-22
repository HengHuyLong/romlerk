import '../../models/ocr_result_model.dart';
import '../../models/driver_license_model.dart';

class DriverLicenseParser {
  /// Parses OCR text from a Cambodian Driver License into a structured model.
  DriverLicense parse(OcrResult result) {
    final rawText = result.fullText ?? "";
    if (rawText.trim().isEmpty) {
      throw Exception("No OCR text found");
    }

    // 🧹 1️⃣ Normalize OCR text
    String text = rawText
        .replaceAll('\n', ' ')
        .replaceAll('\r', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // 🧠 Helper to safely extract and clean values
    String? extract(RegExp pattern) {
      final match = pattern.firstMatch(text);
      if (match == null) return null;

      String value = match.group(1)?.trim() ?? '';
      value = value.replaceAll(RegExp(r'[:\-–]+$'), '').trim();
      return value.isEmpty ? null : value;
    }

    // ===== ✅ REGEX DEFINITIONS (unchanged core logic) =====
    final licenseNoRegex =
        RegExp(r'(?:License\s*No|លេខប័ណ្ណ|លេខបើកបរ)[:\s]+([A-Z0-9.\-\/]+)');
    final idRegex =
        RegExp(r'(?:ID|លេខសម្គាល់|លេខអត្តសញ្ញាណប័ណ្ណ)[:\s]+([A-Z0-9.\-\/]+)');

    // Khmer letters: \u1780-\u17FF ; ASCII letters: A-Za-z ; allow spaces
    final khNameRegex =
        RegExp(r'(?:គោត្តនាមនិងនាម|ឈ្មោះ)[:\s]+([\u1780-\u17FF A-Za-z]+)');
    final enNameRegex =
        RegExp(r'(?:Surname\s*&?\s*Name|Full\s*Name|Name)[:\s]+([A-Za-z\s]+)');
    final genderRegex = RegExp(r'(?:ភេទ|Sex)[:\s]+([\u1780-\u17FFA-Za-z]+)');
    final dobRegex = RegExp(r'(?:កំណើត|Date\s*of\s*Birth)[:\s]+([\d\/.\-]+)');

    // 🌐 Separate Khmer vs English birthplace and nationality
    final placeOfBirthKhRegex =
        RegExp(r'(?:ទីកន្លែងកំណើត)[:\s]+([\u1780-\u17FF\s,]+)');
    final placeOfBirthEnRegex =
        RegExp(r'(?:Place\s*of\s*Birth)[:\s]+([A-Za-z\s,]+)');

    final nationalityKhRegex = RegExp(r'(?:សញ្ជាតិ)[:\s]+([\u1780-\u17FF\s]+)');
    final nationalityEnRegex = RegExp(r'(?:Nationality)[:\s]+([A-Za-z\s]+)');

    final addressRegex = RegExp(
        r'(?:អាសយដ្ឋាន|Address)[:\s]+([\u1780-\u17FFA-Za-z0-9\s,.\-\/]+)');
    final issuedRegex =
        RegExp(r'(?:ថ្ងៃចេញបណ្ណ|Issued\s*Date)[:\s]+([\d\/.\-]+)');
    final expiryRegex =
        RegExp(r'(?:ថ្ងៃផុតកំណត់|Expiry\s*Date)[:\s]+([\d\/.\-]+)');
    final categoryRegex =
        RegExp(r'(?:ប្រភេទ|Categories?)[:\s]+([A-Za-z0-9\s,]+)');
    final specialRegex =
        RegExp(r'(?:លក្ខណៈពិសេស|Special\s*Condition)[:\s]+([A-Za-z0-9\s,]+)');

    // ===== Extract values =====
    final licenseNo = extract(licenseNoRegex);
    final idNumber = extract(idRegex);
    final fullNameKh = extract(khNameRegex);
    final fullNameEn = extract(enNameRegex);
    final gender = extract(genderRegex);
    final dateOfBirth = extract(dobRegex);

    // 🌐 Separate bilingual extraction
    final placeOfBirthKh = extract(placeOfBirthKhRegex);
    final placeOfBirthEn = extract(placeOfBirthEnRegex);
    final nationalityKh = extract(nationalityKhRegex);
    final nationalityEn = extract(nationalityEnRegex);

    final address = extract(addressRegex);
    final dateOfIssue = extract(issuedRegex);
    final dateOfExpiry = extract(expiryRegex);
    final category = extract(categoryRegex);
    final specialCondition = extract(specialRegex);

    // ===== Build model =====
    return DriverLicense(
      licenseNo: licenseNo ?? '',
      idNumber: idNumber ?? '',
      fullNameKh: fullNameKh ?? '',
      fullNameEn: fullNameEn ?? '',
      gender: gender ?? '',
      dateOfBirth: dateOfBirth ?? '',
      placeOfBirthKh: placeOfBirthKh ?? '',
      placeOfBirthEn: placeOfBirthEn ?? '',
      nationalityKh: nationalityKh ?? '',
      nationalityEn: nationalityEn ?? '',
      address: address ?? '',
      dateOfIssue: dateOfIssue ?? '',
      dateOfExpiry: dateOfExpiry ?? '',
      category: category ?? '',
      specialCondition: specialCondition ?? '',
    );
  }
}
