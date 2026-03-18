import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../domain/entities/course_notification.dart';

class NotificationCard extends StatelessWidget {
  final CourseNotification notification;

  const NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: notification.isRead ? AppTheme.cardWhite : AppTheme.primaryGoldLight.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: notification.isRead ? AppTheme.dividerColor : AppTheme.primaryGold.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thông báo lớp học — sẽ phát triển sau'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: notification.isRead
                      ? AppTheme.bgCreamDarker
                      : AppTheme.primaryGold.withOpacity(0.15),
                ),
                child: Icon(
                  notification.isRead ? Icons.notifications_none : Icons.notifications_active,
                  size: 20,
                  color: notification.isRead ? AppTheme.textSecondary : AppTheme.primaryGold,
                ),
              ),
              const SizedBox(width: 12),

              // Nội dung
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên khóa học
                    Text(
                      notification.courseTitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryGoldDark,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Nội dung thông báo
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Thời gian
                    Text(
                      _formatTimeAgo(notification.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Chấm xanh nếu chưa đọc
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryGold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    }
  }
}
