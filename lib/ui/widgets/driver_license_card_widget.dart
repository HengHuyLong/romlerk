import 'package:flutter/material.dart';
import 'package:romlerk/core/theme/app_colors.dart';
import 'package:romlerk/core/theme/app_typography.dart';
import 'package:romlerk/data/models/driver_license_model.dart';

class DriverLicenseCardWidget extends StatelessWidget {
  final DriverLicense license;

  const DriverLicenseCardWidget({super.key, required this.license});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 390),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.darkGray.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          image: const DecorationImage(
            image: AssetImage("assets/images/driving_pattern.jpg"),
            fit: BoxFit.cover,
            opacity: 0.5,
          ),
          color: AppColors.white,
        ),
        padding: const EdgeInsets.all(14),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ====== Top (Name + Photo + Gender Row) ======
              _buildTopSection(context),

              const SizedBox(height: 6),

              // ====== Date of Birth / Place of Birth / Nationality (Below Photo) ======
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _infoBlock(
                      "ថ្ងៃខែឆ្នាំកំណើត\nDate Of Birth",
                      license.dateOfBirth,
                    ),
                  ),
                  Expanded(
                    child: _infoBlock(
                      "Place Of Birth",
                      license.placeOfBirthEn,
                    ),
                  ),
                  Expanded(
                    child: _infoBlock(
                      "Nationality",
                      license.nationalityEn,
                    ),
                  ),
                ],
              ),

              // ====== Address ======
              _infoBlock("អាសយដ្ឋាន Address", license.address),

              const SizedBox(height: 6),

              // ====== Issued + Expiry ======
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _infoBlock(
                      "ថ្ងៃចេញបណ្ណ\nIssued Date",
                      license.dateOfIssue,
                    ),
                  ),
                  Expanded(
                    child: _infoBlock(
                      "ថ្ងៃផុតកំណត់\nExpiry Date",
                      license.dateOfExpiry,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ====== LEFT SIDE: Name + Gender / Birthplace / Nationality ======
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "គោត្តនាម នាម:",
                style: AppTypography.bodyKhBold.copyWith(
                  fontSize: 12,
                  color: AppColors.black,
                ),
              ),
              Text(
                license.fullNameKh ?? "-",
                style: AppTypography.bodyKh.copyWith(
                  fontSize: 12,
                  color: AppColors.black,
                ),
              ),
              Text(
                "Surname & Name:",
                style: AppTypography.body.copyWith(
                  fontSize: 11.5,
                  color: AppColors.black,
                ),
              ),
              Text(
                license.fullNameEn ?? "-",
                style: AppTypography.body.copyWith(
                  fontSize: 11.5,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 10),

              // ====== Gender / Birthplace / Nationality ======
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _inlineField(
                      khLabel: "ភេទ",
                      enLabel: "Sex",
                      value: license.gender,
                    ),
                  ),
                  Expanded(
                    child: _inlineField(
                      khLabel: "ទីកន្លែងកំណើត",
                      enLabel: "",
                      value: license.placeOfBirthKh,
                    ),
                  ),
                  Expanded(
                    child: _inlineField(
                      khLabel: "សញ្ជាតិ",
                      enLabel: "",
                      value: license.nationalityKh,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ====== RIGHT SIDE: License No + Photo + ID ======
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              license.licenseNo ?? "-",
              style: AppTypography.bodyBold.copyWith(
                fontSize: 12,
                color: AppColors.black,
              ),
              textAlign: TextAlign.right,
            ),
            Container(
              width: 70,
              height: 90,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.darkGray),
                borderRadius: BorderRadius.circular(6),
                color: AppColors.white.withValues(alpha: 0.8),
              ),
              child: const Center(
                child: Text(
                  "Photo",
                  style: TextStyle(fontSize: 11, color: Colors.black),
                ),
              ),
            ),
            Text(
              "ID: ${license.idNumber ?? '-'}",
              style: AppTypography.bodyBold.copyWith(
                fontSize: 12,
                color: AppColors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Helper: Combines Khmer + English text if both exist
  String _combineBilingual(String? kh, String? en) {
    if ((kh == null || kh.isEmpty) && (en == null || en.isEmpty)) return "-";
    if (kh != null && kh.isNotEmpty && en != null && en.isNotEmpty) {
      return "$kh\n$en";
    }
    return kh?.isNotEmpty == true ? kh! : en ?? "-";
  }

  /// Inline bilingual label + value field (for compact display)
  Widget _inlineField({
    required String khLabel,
    required String enLabel,
    String? value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "$khLabel ",
                style: AppTypography.bodyKhBold.copyWith(
                  fontSize: 11.5,
                  color: AppColors.black,
                ),
              ),
              Text(
                enLabel,
                style: AppTypography.body.copyWith(
                  fontSize: 11,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          Text(
            value ?? "-",
            style: AppTypography.body.copyWith(
              fontSize: 12,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBlock(String label, String? value) {
    final isKh = label.contains(RegExp(r'[^\x00-\x7F]'));
    final labelStyle =
        (isKh ? AppTypography.bodyKhBold : AppTypography.bodyBold).copyWith(
      fontSize: 11,
      color: AppColors.black,
      height: 1.4,
    );
    final valueStyle =
        (isKh ? AppTypography.bodyKh : AppTypography.body).copyWith(
      fontSize: 12,
      color: AppColors.black,
      height: 1.4,
    );

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),
          Text(value ?? "-", style: valueStyle),
        ],
      ),
    );
  }
}
