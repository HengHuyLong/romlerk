// lib/core/providers/notification_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock/mock_notification_repo.dart';

// Repo provider
final mockNotificationRepoProvider = Provider<MockNotificationRepo>((ref) {
  return MockNotificationRepo();
});

// List of notifications
final notificationListProvider = StateProvider<List<MockNotification>>((ref) {
  final repo = ref.read(mockNotificationRepoProvider);
  return repo.getNotifications();
});

// Count based on list length
final notificationCountProvider = StateProvider<int>((ref) {
  final notifications = ref.watch(notificationListProvider);
  return notifications.length;
});
