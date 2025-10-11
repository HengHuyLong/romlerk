import 'base_document.dart';

class NationalId extends BaseDocument {
  final String? idNumber;
  final String? nameKh;
  final String? nameEn;
  final String? dateOfBirth;
  final String? gender;
  final String? height;
  final String? placeOfBirth;
  final String? address;
  final String? issuedDate;
  final String? expiryDate;
  final String? mrz1;
  final String? mrz2;
  final String? mrz3;
  final String? imageUrl; // ✅ Document image support

  NationalId({
    super.id, // ✅ Firestore/Backend document ID
    this.idNumber,
    this.nameKh,
    this.nameEn,
    this.dateOfBirth,
    this.gender,
    this.height,
    this.placeOfBirth,
    this.address,
    this.issuedDate,
    this.expiryDate,
    this.mrz1,
    this.mrz2,
    this.mrz3,
    this.imageUrl,
  });

  // ✅ Supports both flat JSON and nested { "data": { ... } } backend format
  factory NationalId.fromJson(Map<String, dynamic> json) {
    // Detect if data is nested inside "data"
    final raw =
        json['data'] is Map ? Map<String, dynamic>.from(json['data']) : json;

    return NationalId(
      id: json['id']?.toString(), // always keep top-level id
      idNumber: raw['idNumber'] as String?,
      nameKh: raw['nameKh'] as String?,
      nameEn: raw['nameEn'] as String?,
      dateOfBirth: raw['dateOfBirth'] as String?,
      gender: raw['gender'] as String?,
      height: raw['height'] as String?,
      placeOfBirth: raw['placeOfBirth'] as String?,
      address: raw['address'] as String?,
      issuedDate: raw['issuedDate'] as String?,
      expiryDate: raw['expiryDate'] as String?,
      mrz1: raw['mrz1'] as String?,
      mrz2: raw['mrz2'] as String?,
      mrz3: raw['mrz3'] as String?,
      imageUrl: raw['imageUrl'] as String?,
    );
  }

  @override
  List<DocumentField> toFields() => [
        DocumentField(
          key: "idNumber",
          label: "លេខអត្តសញ្ញាណ",
          value: idNumber,
          type: FieldType.number,
          maxLength: 12,
        ),
        DocumentField(
          key: "nameKh",
          label: "ឈ្មោះជាខ្មែរ",
          value: nameKh,
        ),
        DocumentField(
          key: "nameEn",
          label: "Name (English)",
          value: nameEn,
        ),
        DocumentField(
          key: "dateOfBirth",
          label: "ថ្ងៃខែឆ្នាំកំណើត",
          value: dateOfBirth,
          type: FieldType.date,
        ),
        DocumentField(
          key: "gender",
          label: "ភេទ",
          value: gender,
          type: FieldType.dropdown,
          options: ["ប្រុស", "ស្រី"],
        ),
        DocumentField(
          key: "height",
          label: "កំពស់ (ស.ម)",
          value: height,
          type: FieldType.number,
          maxLength: 3,
        ),
        DocumentField(
          key: "placeOfBirth",
          label: "ទីកន្លែងកំណើត",
          value: placeOfBirth,
          maxLines: 2,
        ),
        DocumentField(
          key: "address",
          label: "អាសយដ្ឋាន",
          value: address,
          maxLines: 2,
        ),
        DocumentField(
          key: "issuedDate",
          label: "សពលភាព",
          value: issuedDate,
          type: FieldType.date,
        ),
        DocumentField(
          key: "expiryDate",
          label: "ដល់ថ្ងៃ",
          value: expiryDate,
          type: FieldType.date,
        ),
      ];

  @override
  NationalId copyWithFields(Map<String, String> updatedFields) {
    return NationalId(
      id: id, // ✅ preserve document ID
      idNumber: updatedFields["idNumber"] ?? idNumber,
      nameKh: updatedFields["nameKh"] ?? nameKh,
      nameEn: updatedFields["nameEn"] ?? nameEn,
      dateOfBirth: updatedFields["dateOfBirth"] ?? dateOfBirth,
      gender: updatedFields["gender"] ?? gender,
      height: updatedFields["height"] ?? height,
      placeOfBirth: updatedFields["placeOfBirth"] ?? placeOfBirth,
      address: updatedFields["address"] ?? address,
      issuedDate: updatedFields["issuedDate"] ?? issuedDate,
      expiryDate: updatedFields["expiryDate"] ?? expiryDate,
      mrz1: mrz1,
      mrz2: mrz2,
      mrz3: mrz3,
      imageUrl: imageUrl,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id, // ✅ include only if available
      'type': 'national_id',
      'idNumber': idNumber,
      'nameKh': nameKh,
      'nameEn': nameEn,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'height': height,
      'placeOfBirth': placeOfBirth,
      'address': address,
      'issuedDate': issuedDate,
      'expiryDate': expiryDate,
      'mrz1': mrz1,
      'mrz2': mrz2,
      'mrz3': mrz3,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}
