import 'package:flutter/material.dart';
import 'package:romlerk/core/theme/app_typography.dart';
import 'package:romlerk/data/models/birth_certificate_model.dart';

class BirthCertificateCardWidget extends StatelessWidget {
  final BirthCertificate cert;

  const BirthCertificateCardWidget({super.key, required this.cert});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 380,
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1.2),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== HEADER =====
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      "ព្រះរាជាណាចក្រកម្ពុជា",
                      style: AppTypography.bodyKh.copyWith(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 34,
                    height: 34,
                    child: Image.asset(
                      "assets/images/ankorlogo.png",
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "ជាតិសាសនាព្រះមហាក្សត្រ",
                      textAlign: TextAlign.right,
                      style: AppTypography.bodyKh.copyWith(
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ===== Title =====
              Align(
                alignment: Alignment.center,
                child: Text(
                  "សំបុត្រកំណើត",
                  style: AppTypography.bodyKhBold.copyWith(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ===== Province / District =====
              _twoFieldRow(
                "ខេត្ត/ក្រុង:",
                cert.province,
                "លេខ:",
                cert.certificateNo,
              ),
              _twoFieldRow(
                "ស្រុក/ខណ្ឌ:",
                cert.district,
                "សៀវភៅបញ្ជាក់កំណើតលេខ:",
                cert.bookNo,
              ),

              const SizedBox(height: 10),

              // ===== CHILD INFO TABLE =====
              Table(
                border: TableBorder.all(color: Colors.black, width: 0.8),
                columnWidths: const {
                  0: FlexColumnWidth(2.5),
                  1: FlexColumnWidth(3.5),
                  2: FlexColumnWidth(1.5),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    children: [
                      // Column 1 — Label
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("នាមត្រកូល",
                                style: AppTypography.bodyKhBold.copyWith(
                                    fontSize: 12, color: Colors.black)),
                            const SizedBox(height: 4),
                            Text("នាមខ្លួនអ្នកកើត",
                                style: AppTypography.bodyKhBold.copyWith(
                                    fontSize: 12, color: Colors.black)),
                          ],
                        ),
                      ),

                      // Column 2 — Khmer name
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cert.surnameKh ?? "-",
                                style: AppTypography.bodyKh.copyWith(
                                    fontSize: 12, color: Colors.black)),
                            const SizedBox(height: 4),
                            Text(cert.givenNameKh ?? "-",
                                style: AppTypography.bodyKh.copyWith(
                                    fontSize: 12, color: Colors.black)),
                          ],
                        ),
                      ),

                      // Column 3 — Gender
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Column(
                          children: [
                            Text("ភេទ:",
                                style: AppTypography.bodyKhBold.copyWith(
                                    fontSize: 12, color: Colors.black)),
                            const SizedBox(height: 4),
                            Text(cert.gender ?? "-",
                                style: AppTypography.bodyKh.copyWith(
                                    fontSize: 12, color: Colors.black)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  _row([
                    "ជាអក្សរឡាតាំង",
                    "${cert.surnameEn ?? ''} ${cert.givenNameEn ?? ''}",
                    ""
                  ]),
                  _row(["សញ្ជាតិ", cert.nationality ?? "-", ""]),
                  _row(["ថ្ងៃ ខែ ឆ្នាំកំណើត", cert.dateOfBirth ?? "-", ""]),
                  _row(["ទីកន្លែងកំណើត", cert.placeOfBirth ?? "-", ""]),
                  _row([
                    "ភូមិ ឃុំ សង្កាត់ ស្រុក ខណ្ឌ ខេត្ត ក្រុង ប្រទេស",
                    "-",
                    ""
                  ]),
                ],
              ),

              const SizedBox(height: 12),

              // ===== PARENTS TABLE =====
              Table(
                border: TableBorder.all(color: Colors.black, width: 0.8),
                columnWidths: const {
                  0: FlexColumnWidth(2.8),
                  1: FlexColumnWidth(3.5),
                  2: FlexColumnWidth(3.5),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  _rowTitle(["ឪពុក / ម្តាយ", "ឪពុក", "ម្តាយ"]),
                  _row([
                    "នាមត្រកូល និង នាមខ្លួន",
                    cert.fatherFullNameKh ?? "-",
                    cert.motherFullNameKh ?? "-"
                  ]),
                  _row([
                    "ជាអក្សរឡាតាំង",
                    cert.fatherFullNameEn ?? "-",
                    cert.motherFullNameEn ?? "-"
                  ]),
                  _row([
                    "សញ្ជាតិ",
                    cert.fatherNationality ?? "-",
                    cert.motherNationality ?? "-"
                  ]),
                  _row([
                    "ថ្ងៃ ខែ ឆ្នាំកំណើត",
                    cert.fatherDateOfBirth ?? "-",
                    cert.motherDateOfBirth ?? "-"
                  ]),
                  _row([
                    "ទីកន្លែងកំណើត ភូមិ ឃុំ សង្កាត់ ស្រុក ខណ្ឌ ខេត្ត ក្រុង ប្រទេស",
                    cert.fatherPlaceOfBirth ?? "-",
                    cert.motherPlaceOfBirth ?? "-"
                  ]),
                ],
              ),

              const SizedBox(height: 16),

              // ===== FOOTER =====
              _footerRow(
                "ធ្វើនៅ:",
                cert.issuedPlace,
                "ថ្ងៃទី ខែ ឆ្នាំ:",
                cert.issuedDate,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Helper methods =====

  Widget _twoFieldRow(
      String label1, String? value1, String label2, String? value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              "$label1 ${value1 ?? '-'}",
              style: AppTypography.bodyKh.copyWith(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$label2 ${value2 ?? '-'}",
              style: AppTypography.bodyKh.copyWith(
                fontSize: 12,
                color: Colors.black,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  TableRow _row(List<String> values) {
    return TableRow(
      children: values
          .map(
            (v) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Text(
                v,
                style: AppTypography.bodyKh.copyWith(
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  TableRow _rowTitle(List<String> titles) {
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFFF5F5F5)),
      children: titles
          .map(
            (t) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
              child: Text(
                t,
                style: AppTypography.bodyKhBold.copyWith(
                  fontSize: 12,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _footerRow(
      String label1, String? value1, String label2, String? value2) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 4, right: 4, bottom: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "$label1 ${value1 ?? '-'}",
              style: AppTypography.bodyKh.copyWith(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              "$label2 ${value2 ?? '-'}",
              style: AppTypography.bodyKh.copyWith(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
