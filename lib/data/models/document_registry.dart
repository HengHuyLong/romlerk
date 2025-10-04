import 'package:flutter/material.dart';
import 'package:romlerk/data/models/document_type.dart';
import 'package:romlerk/data/models/national_id_model.dart';
import 'package:romlerk/ui/screens/scan/document_edit_screen.dart';
import 'package:romlerk/ui/widgets/national_id_card_widget.dart';
import 'package:romlerk/data/models/base_document.dart';

class DocumentConfig {
  final Widget Function(BaseDocument) buildPreview;
  final Widget Function(BaseDocument) buildEdit;

  DocumentConfig({required this.buildPreview, required this.buildEdit});
}

class DocumentRegistry {
  static final registry = <DocumentType, DocumentConfig>{
    DocumentType.nationalId: DocumentConfig(
      buildPreview: (doc) => NationalIdCardWidget(id: doc as NationalId),
      buildEdit: (doc) => DocumentEditScreen(
        type: DocumentType.nationalId,
        document: doc as NationalId,
      ),
    ),
  };
}
