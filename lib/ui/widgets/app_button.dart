import 'package:flutter/material.dart';
import 'package:romlerk/core/theme/app_colors.dart';
import 'package:romlerk/core/theme/app_typography.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isDisabled;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled
              ? AppColors.darkGray.withValues(alpha: 0.4)
              : AppColors.green,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: AppTypography.bodyBold.copyWith(
            fontSize: 16,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
