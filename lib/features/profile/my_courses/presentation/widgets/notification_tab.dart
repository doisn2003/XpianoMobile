import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_theme.dart';
import '../bloc/my_courses_bloc.dart';
import '../bloc/my_courses_event.dart';
import '../bloc/my_courses_state.dart';
import 'notification_card.dart';

class NotificationTab extends StatefulWidget {
  final MyCoursesLoaded state;

  const NotificationTab({super.key, required this.state});

  @override
  State<NotificationTab> createState() => _NotificationTabState();
}

class _NotificationTabState extends State<NotificationTab> {
  @override
  void initState() {
    super.initState();
    if (!widget.state.hasLoadedNotifications && !widget.state.isLoadingNotifications) {
      context.read<MyCoursesBloc>().add(LoadNotifications());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state.isLoadingNotifications) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
    }

    final notifications = widget.state.notifications;
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
