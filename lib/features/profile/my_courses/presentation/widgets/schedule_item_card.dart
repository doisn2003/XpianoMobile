import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../explore/domain/entities/course.dart';

class ScheduleItemCard extends StatelessWidget {
  final CourseSession session;
  final Course course;

  const ScheduleItemCard({
    super.key,
    required this.session,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    // Parse time
    DateTime? sessionStart;
    try {
      sessionStart = DateTime.parse(session.scheduledAt);
    } catch (_) {}

    final startTime = sessionStart != null
        ? '${sessionStart.hour.toString().padLeft(2, '0')}:${sessionStart.minute.toString().padLeft(2, '0')}'
        : '--:--';

    // Tính endTime = startTime + durationMinutes
    DateTime? sessionEnd;
    if (sessionStart != null) {
      sessionEnd = sessionStart.add(Duration(minutes: session.durationMinutes));
    }
    final endTime = sessionEnd != null
        ? '${sessionEnd.hour.toString().padLeft(2, '0')}:${sessionEnd.minute.toString().padLeft(2, '0')}'
        : '--:--';

    // Tính ngày trong tuần
    final weekdayName = sessionStart != null ? _getVietnameseWeekday(sessionStart.weekday) : '';

    // Tính tuần (dựa trên startDate của course)
    String weekLabel = '';
    if (sessionStart != null && course.startDate != null) {
      try {
        final courseStart = DateTime.parse(course.startDate!);
        final diff = sessionStart.difference(courseStart).inDays;
        final weekNumber = (diff / 7).floor() + 1;
        if (weekNumber > 0) weekLabel = 'Tuần $weekNumber';
      } catch (_) {}
    }

    // Location/online info
    final locationInfo = course.isOnline
        ? '$weekdayName, online trên web'
        : '$weekdayName${course.location != null ? ', ${course.location}' : ''}';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.dividerColor, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thông tin chi tiết lớp — sẽ phát triển sau'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==== BÊN TRÁI: Thời gian dọc ====
              SizedBox(
                width: 48,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      startTime,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      endTime,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // ==== Vertical divider ====
              Container(
                width: 3,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),

              // ==== BÊN PHẢI: Nội dung ====
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên khóa/session
                    Text(
                      '${course.id.hashCode.abs() % 900000 + 100000} - ${course.title}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Location / online
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryGold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            locationInfo,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Tuần
                    if (weekLabel.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            weekLabel,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // ==== MŨI TÊN ====
              Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  String _getVietnameseWeekday(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Chiều thứ 2';
      case DateTime.tuesday:
        return 'Chiều thứ 3';
      case DateTime.wednesday:
        return 'Chiều thứ 4';
      case DateTime.thursday:
        return 'Chiều thứ 5';
      case DateTime.friday:
        return 'Chiều thứ 6';
      case DateTime.saturday:
        return 'Sáng thứ 7';
      case DateTime.sunday:
        return 'Chủ nhật';
      default:
        return '';
    }
  }
}
