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

  NationalId({
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
  });

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
          options: ["ប្រុស", "ស្រី"], // ✅ gender dropdown
        ),
        DocumentField(
          key: "height",
          label: "កំពស់ (ស.ម)",
          value: height,
          type: FieldType.number,
          maxLength: 3, // ✅ 3 digits max
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
    );
  }
}
