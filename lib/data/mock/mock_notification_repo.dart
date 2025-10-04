// lib/data/mock/mock_notification_repo.dart
enum NotificationStatus { normal, nearlyExpire, expired }

class MockNotification {
  final String title;
  final String message;
  final DateTime time;
  final NotificationStatus status;

  MockNotification({
    required this.title,
    required this.message,
    required this.time,
    required this.status,
  });
}

class MockNotificationRepo {
  List<MockNotification> getNotifications() {
    return [
      MockNotification(
        title: "Document Reminder",
        message: "Add your document before it expires.",
        time: DateTime.now().subtract(const Duration(hours: 1)),
        status: NotificationStatus.normal,
      ),
      MockNotification(
        title: "Passport Expiry",
        message: "Your passport will expire in 10 days.",
        time: DateTime.now().subtract(const Duration(hours: 1)),
        status: NotificationStatus.nearlyExpire,
      ),
      MockNotification(
        title: "ID Card Renewal",
        message: "Your ID card will expire in 5 days.",
        time: DateTime.now().subtract(const Duration(days: 1)),
        status: NotificationStatus.nearlyExpire,
      ),
      MockNotification(
        title: "Driver’s License",
        message: "Your driver’s license has expired!",
        time: DateTime.now().subtract(const Duration(days: 3)),
        status: NotificationStatus.expired,
      ),
      MockNotification(
        title: "Family Book",
        message: "Update available for family record.",
        time: DateTime.now().subtract(const Duration(days: 5)),
        status: NotificationStatus.normal,
      ),
    ];
  }
}
