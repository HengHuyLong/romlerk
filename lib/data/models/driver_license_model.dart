import 'base_document.dart';

class DriverLicense extends BaseDocument {
  final String? licenseNo; // e.g. B.PP.00221483
  final String? idNumber; // e.g. 0101023456
  final String? fullNameKh; // Khmer full name
  final String? fullNameEn; // English full name
  final String? gender; // M / F
  final String? dateOfBirth; // e.g. 28-07-2001

  // 🌐 Bilingual birthplace
  final String? placeOfBirthKh; // e.g. ភ្នំពេញ
  final String? placeOfBirthEn; // e.g. Phnom Penh

  // 🌐 Bilingual nationality
  final String? nationalityKh; // e.g. ខ្មែរ
  final String? nationalityEn; // e.g. Khmer

  final String? address; // e.g. ភូមិ, ឃុំ, ស្រុក, ខេត្ត
  final String? dateOfIssue; // e.g. 18-02-2020
  final String? dateOfExpiry; // e.g. 18-02-2030
  final String? specialCondition; // e.g. AUTO, Glasses
  final String? category; // e.g. B, C

  DriverLicense({
    super.id,
    super.profileId,
    this.licenseNo,
    this.idNumber,
    this.fullNameKh,
    this.fullNameEn,
    this.gender,
    this.dateOfBirth,
    this.placeOfBirthKh,
    this.placeOfBirthEn,
    this.nationalityKh,
    this.nationalityEn,
    this.address,
    this.dateOfIssue,
    this.dateOfExpiry,
    this.specialCondition,
    this.category,
  }) : super();

  // ✅ Type Identifier
  String get type => 'driver_license';

  // ===============================
  // ✅ Convert to Editable Fields
  // ===============================
  @override
  List<DocumentField> toFields() {
    return [
      DocumentField(key: 'licenseNo', label: 'License No.', value: licenseNo),
      DocumentField(key: 'idNumber', label: 'ID Number', value: idNumber),
      DocumentField(
          key: 'fullNameKh', label: 'Full Name (Khmer)', value: fullNameKh),
      DocumentField(
          key: 'fullNameEn', label: 'Full Name (English)', value: fullNameEn),
      DocumentField(
        key: 'gender',
        label: 'Gender',
        value: gender,
        type: FieldType.dropdown,
        options: ['M', 'F'],
      ),
      DocumentField(
          key: 'dateOfBirth',
          label: 'Date of Birth',
          value: dateOfBirth,
          type: FieldType.date),

      // 🌐 Place of Birth bilingual
      DocumentField(
          key: 'placeOfBirthKh',
          label: 'Place of Birth (Khmer)',
          value: placeOfBirthKh),
      DocumentField(
          key: 'placeOfBirthEn',
          label: 'Place of Birth (English)',
          value: placeOfBirthEn),

      // 🌐 Nationality bilingual
      DocumentField(
          key: 'nationalityKh',
          label: 'Nationality (Khmer)',
          value: nationalityKh),
      DocumentField(
          key: 'nationalityEn',
          label: 'Nationality (English)',
          value: nationalityEn),

      DocumentField(
          key: 'address', label: 'Address', value: address, maxLines: 2),
      DocumentField(
          key: 'dateOfIssue',
          label: 'Issued Date',
          value: dateOfIssue,
          type: FieldType.date),
      DocumentField(
          key: 'dateOfExpiry',
          label: 'Expiry Date',
          value: dateOfExpiry,
          type: FieldType.date),
      DocumentField(
          key: 'specialCondition',
          label: 'Special Condition',
          value: specialCondition),
      DocumentField(key: 'category', label: 'Category', value: category),
    ];
  }

  // ===============================
  // ✅ Update with Editable Fields
  // ===============================
  @override
  DriverLicense copyWithFields(Map<String, String> updatedFields) {
    return DriverLicense(
      id: id,
      profileId: profileId,
      licenseNo: updatedFields['licenseNo'] ?? licenseNo,
      idNumber: updatedFields['idNumber'] ?? idNumber,
      fullNameKh: updatedFields['fullNameKh'] ?? fullNameKh,
      fullNameEn: updatedFields['fullNameEn'] ?? fullNameEn,
      gender: updatedFields['gender'] ?? gender,
      dateOfBirth: updatedFields['dateOfBirth'] ?? dateOfBirth,
      placeOfBirthKh: updatedFields['placeOfBirthKh'] ?? placeOfBirthKh,
      placeOfBirthEn: updatedFields['placeOfBirthEn'] ?? placeOfBirthEn,
      nationalityKh: updatedFields['nationalityKh'] ?? nationalityKh,
      nationalityEn: updatedFields['nationalityEn'] ?? nationalityEn,
      address: updatedFields['address'] ?? address,
      dateOfIssue: updatedFields['dateOfIssue'] ?? dateOfIssue,
      dateOfExpiry: updatedFields['dateOfExpiry'] ?? dateOfExpiry,
      specialCondition: updatedFields['specialCondition'] ?? specialCondition,
      category: updatedFields['category'] ?? category,
    );
  }

  // ===============================
  // ✅ JSON Conversion
  // ===============================
  factory DriverLicense.fromJson(Map<String, dynamic> json) {
    return DriverLicense(
      id: json['id'],
      profileId: json['profileId'],
      licenseNo: json['licenseNo'],
      idNumber: json['idNumber'],
      fullNameKh: json['fullNameKh'],
      fullNameEn: json['fullNameEn'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'],
      placeOfBirthKh: json['placeOfBirthKh'],
      placeOfBirthEn: json['placeOfBirthEn'],
      nationalityKh: json['nationalityKh'],
      nationalityEn: json['nationalityEn'],
      address: json['address'],
      dateOfIssue: json['dateOfIssue'],
      dateOfExpiry: json['dateOfExpiry'],
      specialCondition: json['specialCondition'],
      category: json['category'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "profileId": profileId,
      "type": type,
      "licenseNo": licenseNo,
      "idNumber": idNumber,
      "fullNameKh": fullNameKh,
      "fullNameEn": fullNameEn,
      "gender": gender,
      "dateOfBirth": dateOfBirth,
      "placeOfBirthKh": placeOfBirthKh,
      "placeOfBirthEn": placeOfBirthEn,
      "nationalityKh": nationalityKh,
      "nationalityEn": nationalityEn,
      "address": address,
      "dateOfIssue": dateOfIssue,
      "dateOfExpiry": dateOfExpiry,
      "specialCondition": specialCondition,
      "category": category,
    };
  }
}
