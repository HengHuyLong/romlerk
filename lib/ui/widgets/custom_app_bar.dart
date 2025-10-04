import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../screens/notifications/notification_screen.dart';
import '../../core/providers/notification_provider.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the unread notification count
    final notificationCount = ref.watch(notificationCountProvider);

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.white,
      elevation: 0,
      titleSpacing: 0,
      title: Transform.translate(
        offset:
            const Offset(-20, 0), // shift left if logo has invisible padding
        child: Image.asset(
          AppAssets.logo,
          height: 200,
          fit: BoxFit.contain,
        ),
      ),
      actions: [
        // Notification button with badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: SvgPicture.asset(
                "assets/icons/notification.svg",
                height: 24,
                colorFilter: const ColorFilter.mode(
                  AppColors.darkGray,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationScreen(),
                  ),
                );
              },
            ),
            if (notificationCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.red,
                  child: Text(
                    notificationCount.toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),

        // 📂 Drawer button
        Builder(
          builder: (context) => IconButton(
            icon: SvgPicture.asset(
              "assets/icons/menu.svg",
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.darkGray,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ),
      ],

      // ✅ Add bottom divider line
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppColors.black.withValues(alpha: 0.2),
          height: 1,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}
