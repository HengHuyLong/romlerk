import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white, // fallback color
        image: DecorationImage(
          image: AssetImage(AppAssets.bgTexture), // texture image
          fit: BoxFit.cover,
          opacity: 0.3, // adjust: lower for subtle, higher for stronger
        ),
      ),
      child: child,
    );
  }
}
