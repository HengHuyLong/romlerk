import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ added for logout
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/app_background.dart';
import '../../../core/providers/user_provider.dart';
import '../splash/simple_splash_screen.dart'; // ✅ navigate back to splash

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return AppBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Profile title
              Text(
                "Profile",
                style: AppTypography.h1.copyWith(
                  color: AppColors.darkGray,
                ),
              ),
              const SizedBox(height: 12),

              // 🔹 User info (from provider)
              Text(
                user?.name ?? "Unnamed User",
                style: AppTypography.h3.copyWith(
                  color: AppColors.darkGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                user?.phone ?? "No phone number",
                style: AppTypography.body.copyWith(
                  color: AppColors.darkGray.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 24),

              // 🔹 Settings items
              _buildSettingItem(
                context: context,
                icon: Icons.person_outline,
                label: "Edit Profile",
                onTap: () {},
              ),
              _buildSettingItem(
                context: context,
                icon: Icons.language,
                label: "Language",
                onTap: () {},
              ),
              _buildSettingItem(
                context: context,
                icon: Icons.dark_mode_outlined,
                label: "Dark Mode",
                onTap: () {},
              ),
              _buildSettingItem(
                context: context,
                icon: Icons.credit_card,
                label: "Subscription",
                onTap: () {},
              ),
              _buildSettingItem(
                context: context,
                icon: Icons.receipt_long,
                label: "Transaction History",
                onTap: () {},
              ),
              _buildSettingItem(
                context: context,
                icon: Icons.help_outline,
                label: "FAQ",
                onTap: () {},
              ),
              _buildSettingItem(
                context: context,
                icon: Icons.info_outline,
                label: "About app",
                onTap: () {},
              ),

              const Spacer(),

              // 🔹 Logout with confirmation
              _buildSettingItem(
                context: context,
                icon: Icons.logout,
                label: "Logout",
                color: AppColors.green,
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: AppColors.darkGray.withValues(alpha: 0.2),
                        ),
                      ),
                      title: Text(
                        "Confirm Logout",
                        style: AppTypography.bodyBold.copyWith(
                          color: AppColors.darkGray,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      content: Text(
                        "Are you sure you want to logout?",
                        style: AppTypography.body.copyWith(
                          color: AppColors.darkGray.withValues(alpha: 0.9),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: Text(
                            "Cancel",
                            style: AppTypography.body.copyWith(
                              color: AppColors.darkGray,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: Text(
                            "Logout",
                            style: AppTypography.body.copyWith(
                              color: AppColors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    try {
                      await FirebaseAuth.instance.signOut(); // ✅ sign out user
                      ref
                          .read(userProvider.notifier)
                          .clear(); // ✅ clear user state

                      if (!context.mounted) return;

                      // ✅ Go back to splash entry point
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SimpleSplashScreen(),
                        ),
                        (route) => false,
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Logout failed: $e")),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    Color color = AppColors.darkGray,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: AppTypography.body.copyWith(
          color: color,
          fontWeight: label == "Logout" ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      onTap: onTap,
    );
  }
}
