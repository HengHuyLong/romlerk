import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(
                context,
                index: 0,
                label: "Home",
                icon: "assets/icons/home.svg",
              ),
              _buildNavItem(
                context,
                index: 1,
                label: "Documents",
                icon: "assets/icons/documents.svg",
              ),
              _buildNavItem(
                context,
                index: 2,
                label: "Scan",
                icon: "assets/icons/scan.svg",
              ),
              _buildNavItem(
                context,
                index: 3,
                label: "Setting",
                icon: "assets/icons/setting.svg",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required String label,
    required String icon,
  }) {
    final bool isActive = index == currentIndex;

    return SizedBox(
      width: 80, // ✅ fixed width
      height: 60, // ✅ fixed height
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(100), // circle ripple
          splashColor: AppColors.green.withValues(alpha: 0.2),
          highlightColor: Colors.transparent,
          onTap: () => onTap(index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                tween: Tween<double>(begin: 1.0, end: isActive ? 1.2 : 1.0),
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: SvgPicture.asset(
                      icon,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        isActive ? AppColors.green : AppColors.darkGray,
                        BlendMode.srcIn,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: AppTypography.body.copyWith(
                  fontSize: 11,
                  color: isActive ? AppColors.green : AppColors.darkGray,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
