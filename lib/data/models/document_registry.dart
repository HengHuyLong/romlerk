import 'package:flutter/material.dart';
import 'package:romlerk/data/models/document_type.dart';
import 'package:romlerk/data/models/base_document.dart';

// Models
import 'package:romlerk/data/models/national_id_model.dart';
import 'package:romlerk/data/models/birth_certificate_model.dart';
import 'package:romlerk/data/models/driver_license_model.dart'; // 🆕

// Widgets
import 'package:romlerk/ui/widgets/national_id_card_widget.dart';
import 'package:romlerk/ui/widgets/birth_certificate_card_widget.dart';
import 'package:romlerk/ui/widgets/driver_license_card_widget.dart'; // 🆕

// Screens
import 'package:romlerk/ui/screens/scan/document_edit_screen.dart';

class DocumentConfig {
  final Widget Function(BaseDocument) buildPreview;
  final Widget Function(BaseDocument) buildEdit;

  DocumentConfig({required this.buildPreview, required this.buildEdit});
}

class DocumentRegistry {
  /// 🧠 Dynamic getter — always builds the latest registry when accessed
  static Map<DocumentType, DocumentConfig> get registry {
    final Map<DocumentType, DocumentConfig> map = {};

    // ===== National ID =====
    map[DocumentType.nationalId] = DocumentConfig(
      buildPreview: (doc) => NationalIdCardWidget(id: doc as NationalId),
      buildEdit: (doc) => DocumentEditScreen(
        type: DocumentType.nationalId,
        document: doc as NationalId,
      ),
    );

    // ===== Birth Certificate =====
    map[DocumentType.birthCertificate] = DocumentConfig(
      buildPreview: (doc) =>
          BirthCertificateCardWidget(cert: doc as BirthCertificate),
      buildEdit: (doc) => DocumentEditScreen(
        type: DocumentType.birthCertificate,
        document: doc as BirthCertificate,
      ),
    );

    // ===== Driver License ===== 🆕
    map[DocumentType.drivingLicense] = DocumentConfig(
      buildPreview: (doc) =>
          DriverLicenseCardWidget(license: doc as DriverLicense),
      buildEdit: (doc) => DocumentEditScreen(
        type: DocumentType.drivingLicense,
        document: doc as DriverLicense,
      ),
    );

    // 🧩 Future: Add others dynamically here (Passport, etc.)
    return map;
  }

  /// 🧩 Optional convenience getter
  static DocumentConfig? get(DocumentType type) => registry[type];
}
