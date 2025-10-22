import 'base_document.dart';

class BirthCertificate extends BaseDocument {
  // ===== Top Section =====
  final String? province;
  final String? district;
  final String? commune;
  final String? certificateNo;
  final String? bookNo;
  final String? year;

  // ===== Child Info =====
  final String? surnameKh;
  final String? givenNameKh;
  final String? gender;
  final String? surnameEn;
  final String? givenNameEn;
  final String? nationality;
  final String? dateOfBirth;
  final String? placeOfBirth;

  // ===== Father Info =====
  final String? fatherFullNameKh;
  final String? fatherFullNameEn;
  final String? fatherNationality;
  final String? fatherDateOfBirth;
  final String? fatherPlaceOfBirth;

  // ===== Mother Info =====
  final String? motherFullNameKh;
  final String? motherFullNameEn;
  final String? motherNationality;
  final String? motherDateOfBirth;
  final String? motherPlaceOfBirth;

  // ===== Bottom =====
  final String? issuedPlace;
  final String? issuedDate;
  final String? imageUrl;

  const BirthCertificate({
    super.id,
    super.profileId,
    this.province,
    this.district,
    this.commune,
    this.certificateNo,
    this.bookNo,
    this.year,
    this.surnameKh,
    this.givenNameKh,
    this.gender,
    this.surnameEn,
    this.givenNameEn,
    this.nationality,
    this.dateOfBirth,
    this.placeOfBirth,
    this.fatherFullNameKh,
    this.fatherFullNameEn,
    this.fatherNationality,
    this.fatherDateOfBirth,
    this.fatherPlaceOfBirth,
    this.motherFullNameKh,
    this.motherFullNameEn,
    this.motherNationality,
    this.motherDateOfBirth,
    this.motherPlaceOfBirth,
    this.issuedPlace,
    this.issuedDate,
    this.imageUrl,
  });

  factory BirthCertificate.fromJson(Map<String, dynamic> json) {
    final raw =
        json['data'] is Map ? Map<String, dynamic>.from(json['data']) : json;
    return BirthCertificate(
      id: json['id']?.toString(),
      profileId: raw['profileId'] as String?,
      province: raw['province'],
      district: raw['district'],
      commune: raw['commune'],
      certificateNo: raw['certificateNo'],
      bookNo: raw['bookNo'],
      year: raw['year'],
      surnameKh: raw['surnameKh'],
      givenNameKh: raw['givenNameKh'],
      gender: raw['gender'],
      surnameEn: raw['surnameEn'],
      givenNameEn: raw['givenNameEn'],
      nationality: raw['nationality'],
      dateOfBirth: raw['dateOfBirth'],
      placeOfBirth: raw['placeOfBirth'],
      fatherFullNameKh: raw['fatherFullNameKh'],
      fatherFullNameEn: raw['fatherFullNameEn'],
      fatherNationality: raw['fatherNationality'],
      fatherDateOfBirth: raw['fatherDateOfBirth'],
      fatherPlaceOfBirth: raw['fatherPlaceOfBirth'],
      motherFullNameKh: raw['motherFullNameKh'],
      motherFullNameEn: raw['motherFullNameEn'],
      motherNationality: raw['motherNationality'],
      motherDateOfBirth: raw['motherDateOfBirth'],
      motherPlaceOfBirth: raw['motherPlaceOfBirth'],
      issuedPlace: raw['issuedPlace'],
      issuedDate: raw['issuedDate'],
      imageUrl: raw['imageUrl'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    return {
      ...json,
      'type': 'birth_certificate',
      'province': province,
      'district': district,
      'commune': commune,
      'certificateNo': certificateNo,
      'bookNo': bookNo,
      'year': year,
      'surnameKh': surnameKh,
      'givenNameKh': givenNameKh,
      'gender': gender,
      'surnameEn': surnameEn,
      'givenNameEn': givenNameEn,
      'nationality': nationality,
      'dateOfBirth': dateOfBirth,
      'placeOfBirth': placeOfBirth,
      'fatherFullNameKh': fatherFullNameKh,
      'fatherFullNameEn': fatherFullNameEn,
      'fatherNationality': fatherNationality,
      'fatherDateOfBirth': fatherDateOfBirth,
      'fatherPlaceOfBirth': fatherPlaceOfBirth,
      'motherFullNameKh': motherFullNameKh,
      'motherFullNameEn': motherFullNameEn,
      'motherNationality': motherNationality,
      'motherDateOfBirth': motherDateOfBirth,
      'motherPlaceOfBirth': motherPlaceOfBirth,
      'issuedPlace': issuedPlace,
      'issuedDate': issuedDate,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  @override
  BirthCertificate copyWithFields(Map<String, String> updatedFields) {
    return BirthCertificate(
      id: id,
      profileId: profileId,
      province: updatedFields['province'] ?? province,
      district: updatedFields['district'] ?? district,
      commune: updatedFields['commune'] ?? commune,
      certificateNo: updatedFields['certificateNo'] ?? certificateNo,
      bookNo: updatedFields['bookNo'] ?? bookNo,
      year: updatedFields['year'] ?? year,
      surnameKh: updatedFields['surnameKh'] ?? surnameKh,
      givenNameKh: updatedFields['givenNameKh'] ?? givenNameKh,
      gender: updatedFields['gender'] ?? gender,
      surnameEn: updatedFields['surnameEn'] ?? surnameEn,
      givenNameEn: updatedFields['givenNameEn'] ?? givenNameEn,
      nationality: updatedFields['nationality'] ?? nationality,
      dateOfBirth: updatedFields['dateOfBirth'] ?? dateOfBirth,
      placeOfBirth: updatedFields['placeOfBirth'] ?? placeOfBirth,
      fatherFullNameKh: updatedFields['fatherFullNameKh'] ?? fatherFullNameKh,
      fatherFullNameEn: updatedFields['fatherFullNameEn'] ?? fatherFullNameEn,
      fatherNationality:
          updatedFields['fatherNationality'] ?? fatherNationality,
      fatherDateOfBirth:
          updatedFields['fatherDateOfBirth'] ?? fatherDateOfBirth,
      fatherPlaceOfBirth:
          updatedFields['fatherPlaceOfBirth'] ?? fatherPlaceOfBirth,
      motherFullNameKh: updatedFields['motherFullNameKh'] ?? motherFullNameKh,
      motherFullNameEn: updatedFields['motherFullNameEn'] ?? motherFullNameEn,
      motherNationality:
          updatedFields['motherNationality'] ?? motherNationality,
      motherDateOfBirth:
          updatedFields['motherDateOfBirth'] ?? motherDateOfBirth,
      motherPlaceOfBirth:
          updatedFields['motherPlaceOfBirth'] ?? motherPlaceOfBirth,
      issuedPlace: updatedFields['issuedPlace'] ?? issuedPlace,
      issuedDate: updatedFields['issuedDate'] ?? issuedDate,
      imageUrl: imageUrl,
    );
  }

  @override
  List<DocumentField> toFields() {
    return [
      DocumentField(key: "province", label: "ខេត្ត/ក្រុង", value: province),
      DocumentField(key: "district", label: "ស្រុក/ខណ្ឌ", value: district),
      DocumentField(key: "commune", label: "ឃុំ/សង្កាត់", value: commune),
      DocumentField(key: "certificateNo", label: "លេខ", value: certificateNo),
      DocumentField(
          key: "bookNo", label: "សៀវភៅបញ្ជាក់កំណើតលេខ", value: bookNo),
      DocumentField(key: "year", label: "ឆ្នាំ", value: year),
      DocumentField(key: "surnameKh", label: "នាមត្រកូល", value: surnameKh),
      DocumentField(
          key: "givenNameKh", label: "នាមខ្លួនអ្នកកើត", value: givenNameKh),
      DocumentField(
          key: "gender",
          label: "ភេទ",
          value: gender,
          type: FieldType.dropdown,
          options: ["ប្រុស", "ស្រី"]),
      DocumentField(
          key: "surnameEn", label: "នាមត្រកូល (អក្សរឡាតាំង)", value: surnameEn),
      DocumentField(
          key: "givenNameEn",
          label: "នាមខ្លួន (អក្សរឡាតាំង)",
          value: givenNameEn),
      DocumentField(key: "nationality", label: "សញ្ជាតិ", value: nationality),
      DocumentField(
          key: "dateOfBirth",
          label: "ថ្ងៃ ខែ ឆ្នាំកំណើត",
          value: dateOfBirth,
          type: FieldType.date),
      DocumentField(
          key: "placeOfBirth", label: "ទីកន្លែងកំណើត", value: placeOfBirth),
      DocumentField(
          key: "fatherFullNameKh",
          label: "ឈ្មោះឪពុក (នាមត្រកូល និង នាមខ្លួន)",
          value: fatherFullNameKh),
      DocumentField(
          key: "fatherFullNameEn",
          label: "ឪពុក (អក្សរឡាតាំង)",
          value: fatherFullNameEn),
      DocumentField(
          key: "fatherNationality",
          label: "សញ្ជាតិឪពុក",
          value: fatherNationality),
      DocumentField(
          key: "fatherDateOfBirth",
          label: "ថ្ងៃ ខែ ឆ្នាំកំណើតឪពុក",
          value: fatherDateOfBirth,
          type: FieldType.date),
      DocumentField(
          key: "fatherPlaceOfBirth",
          label: "ទីកន្លែងកំណើតឪពុក",
          value: fatherPlaceOfBirth),
      DocumentField(
          key: "motherFullNameKh",
          label: "ឈ្មោះម្តាយ (នាមត្រកូល និង នាមខ្លួន)",
          value: motherFullNameKh),
      DocumentField(
          key: "motherFullNameEn",
          label: "ម្តាយ (អក្សរឡាតាំង)",
          value: motherFullNameEn),
      DocumentField(
          key: "motherNationality",
          label: "សញ្ជាតិម្តាយ",
          value: motherNationality),
      DocumentField(
          key: "motherDateOfBirth",
          label: "ថ្ងៃ ខែ ឆ្នាំកំណើតម្តាយ",
          value: motherDateOfBirth,
          type: FieldType.date),
      DocumentField(
          key: "motherPlaceOfBirth",
          label: "ទីកន្លែងកំណើតម្តាយ",
          value: motherPlaceOfBirth),
      DocumentField(key: "issuedPlace", label: "ធ្វើនៅ", value: issuedPlace),
      DocumentField(
          key: "issuedDate",
          label: "ថ្ងៃ ខែ ឆ្នាំចេញ",
          value: issuedDate,
          type: FieldType.date),
    ];
  }
}
