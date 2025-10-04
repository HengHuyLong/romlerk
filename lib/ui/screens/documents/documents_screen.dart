import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_colors.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Documents Screen",
        style: AppTypography.h2.copyWith(
          color: AppColors.darkGray,
        ),
      ),
    );
  }
}
