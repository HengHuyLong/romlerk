import 'package:flutter/material.dart';
import 'package:romlerk/core/theme/app_colors.dart';
import 'package:romlerk/core/theme/app_typography.dart';
import 'package:romlerk/data/models/national_id_model.dart';

class NationalIdCardWidget extends StatelessWidget {
  final NationalId id;

  const NationalIdCardWidget({super.key, required this.id});

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
            image: AssetImage("assets/images/ankor_background.jpg"),
            fit: BoxFit.cover,
            opacity: 0.2,
          ),
          color: AppColors.white,
        ),
        padding: const EdgeInsets.all(14),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row: Photo + Names + ID number top right
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 70,
                    height: 90,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.darkGray),
                      borderRadius: BorderRadius.circular(6),
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                    child: Center(
                      child: Text(
                        "Photo",
                        style: AppTypography.body.copyWith(
                          color: AppColors.black,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "គោត្តនាមនិងនាម:\n${id.nameKh ?? ''}\n${id.nameEn ?? ''}",
                          style: AppTypography.bodyBold.copyWith(
                            fontSize: 12,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Birthday
                        _field("ថ្ងៃខែឆ្នាំកំណើត:", id.dateOfBirth),

                        // ✅ Gender and Height tighter together
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: _field(
                                "ភេទ:",
                                id.gender,
                                compact: true,
                                removeRightPadding: true,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: _field(
                                "កំពស់:",
                                id.height != null && id.height!.isNotEmpty
                                    ? "${id.height} ស.ម"
                                    : "-",
                                compact: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        id.idNumber ?? "-",
                        style: AppTypography.bodyBold.copyWith(
                          fontSize: 12,
                          color: AppColors.black,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),
              _field("ទីកន្លែងកំណើត: ", id.placeOfBirth, fullWidth: true),
              const SizedBox(height: 4),
              _field("អាសយដ្ឋាន: ", id.address, fullWidth: true),

              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(child: _field("សពលភាព:", id.issuedDate)),
                  Expanded(child: _field("ដល់ថ្ងៃ:", id.expiryDate)),
                ],
              ),

              const SizedBox(height: 6),
              Text(
                "ភិនភាគ:",
                style: AppTypography.bodyKhBold.copyWith(
                  fontSize: 11,
                  color: AppColors.black,
                ),
              ),
              if (id.mrz1 != null) _monospace(id.mrz1!),
              if (id.mrz2 != null) _monospace(id.mrz2!),
              if (id.mrz3 != null) _monospace(id.mrz3!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    String? value, {
    bool fullWidth = false,
    bool compact = false,
    bool removeRightPadding = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 3,
        right: removeRightPadding ? 0 : 4, // ✅ tighter spacing
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: fullWidth
                ? null
                : compact
                    ? 50 // ✅ slightly smaller label for compact rows
                    : 90,
            child: Text(
              label,
              style: AppTypography.bodyBold.copyWith(
                fontSize: 12,
                color: AppColors.black,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? "-",
              style: AppTypography.body.copyWith(
                fontSize: 12,
                color: AppColors.black,
              ),
              softWrap: true,
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }

  Widget _monospace(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: "monospace",
        fontSize: 11,
        letterSpacing: 5,
        color: Colors.black,
      ),
    );
  }
}
