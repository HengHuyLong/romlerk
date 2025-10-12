/// A single editable field in a document form.
enum FieldType { text, date, number, dropdown }

class DocumentField {
  final String key; // e.g. "idNumber"
  final String label; // e.g. "ID Number"
  final String? value; // initial value from OCR or backend
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

/// Base class that all document models must extend.
/// Handles shared metadata such as Firestore document ID.
abstract class BaseDocument {
  /// Optional Firestore document ID.
  final String? id;

  /// Optional profile ID for sub-profile documents (e.g. Dad, Mom, etc.)
  final String? profileId; // ✅ Added field

  const BaseDocument({
    this.id,
    this.profileId, // ✅ Added to constructor
  });

  /// Returns the list of editable fields for the document.
  List<DocumentField> toFields();

  /// Returns a new instance of the document with updated field values.
  BaseDocument copyWithFields(Map<String, String> updatedFields);

  /// Converts this document to a JSON-serializable map for backend or local storage.
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    if (id != null) {
      data['id'] = id;
    }

    if (profileId != null) {
      data['profileId'] = profileId; // ✅ now enclosed in block
    }

    return data;
  }
}
