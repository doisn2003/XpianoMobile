import 'package:flutter/material.dart';

import '../../domain/entities/course_notification.dart';
import 'notification_card.dart';

class NotificationTab extends StatelessWidget {
  final List<CourseNotification> notifications;

  const NotificationTab({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'Chưa có thông báo nào',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return NotificationCard(notification: notifications[index]);
      },
    );
  }
}
