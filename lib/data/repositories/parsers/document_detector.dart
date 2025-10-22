import '../../models/document_type.dart';

class DocumentDetector {
  DocumentType detect(String text) {
    final lower = text.toLowerCase();

    // 🔹 Normalize OCR output by removing spaces, punctuation & zero-width chars
    final cleaned = lower
        .replaceAll(RegExp(r'[\s\p{P}]+', unicode: true), '')
        .replaceAll(RegExp(r'[\u200B-\u200D]'), ''); // remove zero-width chars

    // 🪪 NATIONAL ID
    if (cleaned.contains("អត្តសញ្ញាណប័ណ្ណ") || cleaned.contains("idkhm")) {
      return DocumentType.nationalId;
    }

    // 🛂 PASSPORT
    if (cleaned.contains("passport") ||
        cleaned.contains("pk<khm") ||
        cleaned.contains("កាសសន្ដិ")) {
      return DocumentType.passport;
    }

    // 👶 BIRTH CERTIFICATE (Khmer & English)
    final hasBirthKeywords = cleaned.contains("វិញ្ញាបនបត្រកំណើត") ||
        cleaned.contains("សំបុត្រកំណើត") ||
        cleaned.contains("birthcertificate") ||
        cleaned.contains("certificateofbirth");

    final hasParentInfo = lower.contains("ឪពុក") ||
        lower.contains("ម្តាយ") ||
        lower.contains("father") ||
        lower.contains("mother");

    if (hasBirthKeywords || hasParentInfo) {
      return DocumentType.birthCertificate;
    }

    // 🚗 DRIVING LICENSE (Khmer & English)
    if (cleaned.contains("drivinglicense") ||
        lower.contains("driving licence") || // 🇬🇧 alternate spelling
        cleaned.contains("បណ្ណបើកបរ") ||
        cleaned.contains("bannbokbor") ||
        cleaned.contains("specialcondition") || // 🆕 OCR English label
        lower.contains("special condition") || // 🆕 OCR English label
        cleaned.contains("categories")) {
      // 🆕 OCR English label
      return DocumentType.drivingLicense;
    }

    return DocumentType.unknown;
  }
}
