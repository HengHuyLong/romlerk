import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../data/mock/mock_notification_repo.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationListProvider);

    // Clear unread badge count when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationCountProvider.notifier).state = 0;
    });

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: AppColors.darkGray,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Notifications",
                    style: AppTypography.h1.copyWith(
                      color: AppColors.darkGray,
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Notifications list
            Expanded(
              child: notifications.isEmpty
                  ? Center(
                      child: Text(
                        "No notifications yet",
                        style: AppTypography.bodyBold.copyWith(
                          color: AppColors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final n = notifications[index];

                        // Background color logic
                        Color bgColor;
                        switch (n.status) {
                          case NotificationStatus.expired:
                            bgColor = Colors.red.withValues(alpha: 0.1);
                            break;
                          case NotificationStatus.nearlyExpire:
                            bgColor = Colors.yellow.withValues(alpha: 0.2);
                            break;
                          default:
                            bgColor = AppColors.white;
                        }

                        return Dismissible(
                          key: ValueKey(n.title + n.time.toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            color: Colors.red,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (_) async {
                            // ✅ Ask for confirmation with styled dialog
                            final result = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: AppColors.darkGray.withValues(
                                        alpha: 0.2), // subtle border
                                  ),
                                ),
                                title: Text(
                                  "Delete Notification",
                                  style: AppTypography.bodyBold.copyWith(
                                    color: AppColors.darkGray,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                content: Text(
                                  "Are you sure you want to delete this notification?",
                                  style: AppTypography.body.copyWith(
                                    color: AppColors.darkGray
                                        .withValues(alpha: 0.9),
                                  ),
                                ),
                                actionsPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                actions: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.darkGray,
                                      textStyle: AppTypography.body.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      textStyle: AppTypography.body.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    child: const Text("Delete"),
                                  ),
                                ],
                              ),
                            );
                            return result ?? false;
                          },
                          onDismissed: (_) {
                            // ✅ Delete only if confirmed
                            final currentList = [
                              ...ref.read(notificationListProvider)
                            ];
                            currentList.removeAt(index);
                            ref.read(notificationListProvider.notifier).state =
                                currentList;
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                color: AppColors.green.withValues(alpha: 0.15),
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 🔹 Status dot
                                Container(
                                  width: 10,
                                  height: 10,
                                  margin:
                                      const EdgeInsets.only(top: 6, right: 12),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: n.status ==
                                            NotificationStatus.expired
                                        ? Colors.red
                                        : (n.status ==
                                                NotificationStatus.nearlyExpire
                                            ? Colors.orange
                                            : Colors.grey),
                                  ),
                                ),

                                // 🔹 Texts
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        n.title,
                                        style: AppTypography.bodyBold.copyWith(
                                          color: AppColors.darkGray,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        n.message,
                                        style: AppTypography.body.copyWith(
                                          color: AppColors.darkGray
                                              .withValues(alpha: 0.9),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _formatTime(n.time),
                                        style: AppTypography.body.copyWith(
                                          fontSize: 12,
                                          color: AppColors.darkGray
                                              .withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else {
      return "${difference.inDays}d ago";
    }
  }
}
