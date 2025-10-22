import '../../models/ocr_result_model.dart';
import '../../models/birth_certificate_model.dart';

class BirthCertificateParser {
  BirthCertificate parse(OcrResult result) {
    final text = result.fullText ?? "";
    final lines = text
        .split(RegExp(r'\n+'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // ===== Regex patterns =====
    final numberRegex = RegExp(r'(?:លេខ[:\s]*)?(\d{3,6})');
    final yearRegex = RegExp(r'(?:ឆ្នាំ[:\s]*)?(\d{4})');
    final dateRegex = RegExp(r'(\d{1,2}[/-]\d{1,2}[/-]\d{4})');
    final genderRegex =
        RegExp(r'(ប្រុស|ស្រី|male|female)', caseSensitive: false);

    // ✅ Location regex with clean group capture
    final provinceRegex =
        RegExp(r'(?:ខេត្ត|ក្រុង)\s*[:\-]?\s*([ក-ហA-Za-z0-9\s]+)');
    final districtRegex =
        RegExp(r'(?:ស្រុក|ខណ្ឌ)\s*[:\-]?\s*([ក-ហA-Za-z0-9\s]+)');
    final communeRegex =
        RegExp(r'(?:ឃុំ|សង្កាត់)\s*[:\-]?\s*([ក-ហA-Za-z0-9\s]+)');

    final fatherRegex = RegExp(r'(?:ឪពុក|father)', caseSensitive: false);
    final motherRegex = RegExp(r'(?:ម្តាយ|mother)', caseSensitive: false);
    final nationalityRegex = RegExp(r'(?:សញ្ជាតិ[:\s]*)([ក-ហA-Za-z]+)');
    final placeOfBirthRegex =
        RegExp(r'(?:ទីកន្លែងកំណើត[:\s]*)([ក-ហA-Za-z0-9\s]+)');
    final dateOfBirthRegex = RegExp(
        r'(?:ថ្ងៃ.?ខែ.?ឆ្នាំ.?កំណើត[:\s]*)(\d{1,2}[/-]\d{1,2}[/-]\d{4})');

    // ===== Extract main fields =====
    final certificateNo = numberRegex.firstMatch(text)?.group(1);
    final year = yearRegex.firstMatch(text)?.group(1);
    final gender = _normalizeGender(genderRegex.firstMatch(text)?.group(1));
    final dates = dateRegex.allMatches(text).map((m) => m.group(1)).toList();

    final province =
        _cleanLocation(provinceRegex.firstMatch(text)?.group(1)?.trim());
    final district =
        _cleanLocation(districtRegex.firstMatch(text)?.group(1)?.trim());
    final commune =
        _cleanLocation(communeRegex.firstMatch(text)?.group(1)?.trim());

    // ===== Extract child names =====
    String? surnameKh, givenNameKh, surnameEn, givenNameEn;
    for (var line in lines) {
      if (RegExp(r'^[\u1780-\u17FF ]+$').hasMatch(line)) {
        surnameKh ??= line.split(' ').first;
        givenNameKh ??= line.split(' ').skip(1).join(' ');
      } else if (RegExp(r'^[A-Z ]+$').hasMatch(line)) {
        surnameEn ??= line.split(' ').first;
        givenNameEn ??= line.split(' ').skip(1).join(' ');
      }
    }

    // ===== Extract parent info =====
    String? fatherFullNameKh,
        fatherFullNameEn,
        fatherNationality,
        fatherDateOfBirth,
        fatherPlaceOfBirth;

    String? motherFullNameKh,
        motherFullNameEn,
        motherNationality,
        motherDateOfBirth,
        motherPlaceOfBirth;

    for (int i = 0; i < lines.length; i++) {
      final l = lines[i];

      // ===== Father Section =====
      if (fatherRegex.hasMatch(l)) {
        fatherFullNameKh = _findNextKhmer(lines, i);
        fatherFullNameEn = _findNextEnglish(lines, i);
        fatherNationality = _findBelow(lines, i, nationalityRegex);
        fatherDateOfBirth = _findBelow(lines, i, dateOfBirthRegex);
        fatherPlaceOfBirth = _findBelow(lines, i, placeOfBirthRegex);
      }

      // ===== Mother Section =====
      if (motherRegex.hasMatch(l)) {
        motherFullNameKh = _findNextKhmer(lines, i);
        motherFullNameEn = _findNextEnglish(lines, i);
        motherNationality = _findBelow(lines, i, nationalityRegex);
        motherDateOfBirth = _findBelow(lines, i, dateOfBirthRegex);
        motherPlaceOfBirth = _findBelow(lines, i, placeOfBirthRegex);
      }
    }

    // ===== Issued date/place (bottom section) =====
    String? issuedPlace;
    String? issuedDate;
    for (var l in lines.reversed) {
      if (l.contains("ធ្វើនៅ")) {
        issuedPlace = _cleanLocation(l.replaceAll(RegExp(r'[^ក-ហ\s]'), ''));
      }
      if (dateRegex.hasMatch(l)) {
        issuedDate = dateRegex.firstMatch(l)?.group(1);
        break;
      }
    }

    // ===== Return structured model =====
    return BirthCertificate(
      certificateNo: certificateNo,
      year: year,
      gender: gender,
      province: province,
      district: district,
      commune: commune,
      surnameKh: surnameKh,
      givenNameKh: givenNameKh,
      surnameEn: surnameEn,
      givenNameEn: givenNameEn,
      dateOfBirth: dates.isNotEmpty ? dates.first : null,
      issuedPlace: issuedPlace,
      issuedDate: issuedDate,
      fatherFullNameKh: fatherFullNameKh,
      fatherFullNameEn: fatherFullNameEn,
      fatherNationality: fatherNationality,
      fatherDateOfBirth: fatherDateOfBirth,
      fatherPlaceOfBirth: fatherPlaceOfBirth,
      motherFullNameKh: motherFullNameKh,
      motherFullNameEn: motherFullNameEn,
      motherNationality: motherNationality,
      motherDateOfBirth: motherDateOfBirth,
      motherPlaceOfBirth: motherPlaceOfBirth,
    );
  }

  // ===== Helper Methods =====

  /// Find next Khmer line after the given index
  String? _findNextKhmer(List<String> lines, int from) {
    for (var i = from + 1; i < lines.length; i++) {
      if (RegExp(r'[\u1780-\u17FF]').hasMatch(lines[i])) return lines[i];
    }
    return null;
  }

  /// Find next English (Latin) line after the given index
  String? _findNextEnglish(List<String> lines, int from) {
    for (var i = from + 1; i < lines.length; i++) {
      if (RegExp(r'^[A-Z ]+$').hasMatch(lines[i])) return lines[i];
    }
    return null;
  }

  /// Find the first line below index that matches regex
  String? _findBelow(List<String> lines, int from, RegExp pattern) {
    for (var i = from + 1; i < lines.length; i++) {
      if (pattern.hasMatch(lines[i])) {
        return pattern.firstMatch(lines[i])?.group(1)?.trim();
      }
    }
    return null;
  }

  /// Normalize gender values into Khmer form
  String? _normalizeGender(String? raw) {
    if (raw == null) return null;
    final g = raw.toLowerCase();
    if (g.contains("m") || g.contains("ប្រុស")) return "ប្រុស";
    if (g.contains("f") || g.contains("ស្រី")) return "ស្រី";
    return null;
  }

  /// Remove Khmer headers like ខេត្ត / ស្រុក / ឃុំ / សង្កាត់
  String? _cleanLocation(String? text) {
    if (text == null) return null;
    return text
        .replaceAll(RegExp(r'(ខេត្ត|ក្រុង|ស្រុក|ខណ្ឌ|ឃុំ|សង្កាត់|ធ្វើនៅ)'), '')
        .trim();
  }
}
