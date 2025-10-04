import '../../models/document_type.dart';

class DocumentDetector {
  DocumentType detect(String text) {
    final lower = text.toLowerCase();

    if (lower.contains("អត្តសញ្ញាណប័ណ្ណ") || lower.contains("idkhm")) {
      return DocumentType.nationalId;
    }
    if (lower.contains("passport") ||
        lower.contains("pk<khm") ||
        lower.contains("កាសសន្ដិ")) {
      return DocumentType.passport;
    }
    if (lower.contains("វិញ្ញាបនបត្រកំណើត")) {
      return DocumentType.birthCertificate;
    }
    if (lower.contains("driving license") || lower.contains("ប័ណ្ណបើកបរ")) {
      return DocumentType.drivingLicense;
    }

    return DocumentType.unknown;
  }
}
