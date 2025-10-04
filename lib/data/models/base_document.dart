// lib/data/models/base_document.dart

/// A single editable field in a document form.
enum FieldType { text, date, number, dropdown }

class DocumentField {
  final String key; // e.g. "idNumber"
  final String label; // e.g. "ID Number"
  final String? value; // initial value from OCR
  final int maxLines; // for multiline fields like address
  final List<String>? options; // for dropdowns like gender
  final int? maxLength; // optional numeric limit
  final FieldType type;

  const DocumentField({
    required this.key,
    required this.label,
    this.value,
    this.maxLines = 1,
    this.type = FieldType.text,
    this.options,
    this.maxLength,
  });
}

/// Base interface that all document models should implement
/// to power the generic edit form.
abstract class BaseDocument {
  /// Provide the list of editable fields for this document.
  List<DocumentField> toFields();

  /// Return a new instance of the document with the given fields updated.
  BaseDocument copyWithFields(Map<String, String> updatedFields);
}
