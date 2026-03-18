import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../domain/entities/assignment.dart';

class AssignmentCard extends StatelessWidget {
  final Assignment assignment;

  const AssignmentCard({super.key, required this.assignment});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.dividerColor, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bài tập cá nhân — sẽ phát triển sau'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tên khóa học
              Text(
                assignment.courseTitle,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryGoldDark,
                ),
              ),
              const SizedBox(height: 6),

              // Tên bài tập
              Text(
                assignment.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),

              // Hạn nộp + trạng thái
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Hạn: ${DateFormat('dd/MM/yyyy HH:mm').format(assignment.dueDate)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  _buildStatusChip(assignment.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'submitted':
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        label = 'Đã nộp';
        break;
      case 'graded':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        label = 'Đã chấm';
        break;
      case 'pending':
      default:
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        label = 'Chưa nộp';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
