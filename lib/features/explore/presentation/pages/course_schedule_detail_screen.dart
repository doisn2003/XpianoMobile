import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/course.dart';
import '../../domain/repositories/course_repository.dart';
import '../bloc/course_schedule_bloc.dart';
import '../bloc/course_schedule_event.dart';
import '../bloc/course_schedule_state.dart';

class CourseScheduleDetailScreen extends StatelessWidget {
  final String courseId;
  final bool isTeacher;

  const CourseScheduleDetailScreen({
    super.key,
    required this.courseId,
    required this.isTeacher,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CourseScheduleBloc>(
      create: (_) => CourseScheduleBloc(courseRepository: di.sl<CourseRepository>())
        ..add(LoadCourseSchedule(courseId: courseId, isTeacher: isTeacher)),
      child: _ScheduleDetailView(isTeacher: isTeacher),
    );
  }
}

class _ScheduleDetailView extends StatelessWidget {
  final bool isTeacher;

  const _ScheduleDetailView({required this.isTeacher});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text('Chi tiết lịch học'),
        backgroundColor: AppTheme.cardWhite,
      ),
      body: BlocBuilder<CourseScheduleBloc, CourseScheduleState>(
        builder: (context, state) {
          if (state is CourseScheduleLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
          }

          if (state is CourseScheduleError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(state.message, style: const TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            );
          }

          if (state is CourseScheduleLoaded) {
            return _buildContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, CourseScheduleLoaded state) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Course header card
          _buildCourseHeader(state),

          // Tab bar
          Container(
            color: AppTheme.cardWhite,
            child: const TabBar(
              indicatorColor: AppTheme.primaryGold,
              labelColor: AppTheme.primaryGoldDark,
              unselectedLabelColor: AppTheme.textSecondary,
              labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              tabs: [
                Tab(text: 'Học viên'),
                Tab(text: 'Các buổi học'),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              children: [
                _buildEnrollmentList(state),
                _buildSessionList(state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseHeader(CourseScheduleLoaded state) {
    final course = state.course;
    final progress = state.totalSessions > 0 ? state.completedSessions / state.totalSessions : 0.0;

    return Container(
      color: AppTheme.cardWhite,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          if (course.teacher != null)
            Text(
              'GV: ${course.teacher!.fullName}',
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
          const SizedBox(height: 12),

          // Stats row
          Row(
            children: [
              _buildStatChip(Icons.people, '${course.enrolledCount} học viên'),
              const SizedBox(width: 12),
              _buildStatChip(Icons.calendar_today, '${state.totalSessions} buổi'),
              const SizedBox(width: 12),
              _buildStatChip(Icons.check_circle_outline, '${state.completedSessions} hoàn thành'),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppTheme.bgCreamDarker,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGold),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${state.completedSessions}/${state.totalSessions}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryGold),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildEnrollmentList(CourseScheduleLoaded state) {
    if (!isTeacher) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people, size: 48, color: AppTheme.primaryGold),
            const SizedBox(height: 12),
            Text(
              'Tổng ${state.course.enrolledCount} học viên',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text('Chỉ giáo viên mới xem được danh sách chi tiết', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          ],
        ),
      );
    }

    if (state.enrollments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: AppTheme.textSecondary.withOpacity(0.3)),
            const SizedBox(height: 12),
            const Text('Chưa có học viên nào', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.enrollments.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: AppTheme.dividerColor),
      itemBuilder: (context, index) {
        final enrollment = state.enrollments[index];
        final user = enrollment.user;
        return ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.primaryGold.withOpacity(0.15),
            backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
            child: user?.avatarUrl == null
                ? Text(
                    user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : '?',
                    style: const TextStyle(color: AppTheme.primaryGoldDark, fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          title: Text(user?.fullName ?? 'Học viên', style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: enrollment.createdAt != null
              ? Text(
                  'Tham gia: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(enrollment.createdAt!))}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                )
              : null,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('Active', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600)),
          ),
        );
      },
    );
  }

  Widget _buildSessionList(CourseScheduleLoaded state) {
    if (state.sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: AppTheme.textSecondary.withOpacity(0.3)),
            const SizedBox(height: 12),
            const Text('Chưa có buổi học nào', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.sessions.length,
      itemBuilder: (context, index) {
        final session = state.sessions[index];
        return _buildSessionTile(session, index + 1);
      },
    );
  }

  Widget _buildSessionTile(CourseSession session, int number) {
    final scheduledDate = DateTime.tryParse(session.scheduledAt);
    final dateStr = scheduledDate != null ? DateFormat('dd/MM/yyyy – HH:mm').format(scheduledDate) : session.scheduledAt;

    Color statusColor;
    String statusLabel;
    switch (session.status) {
      case 'ended':
        statusColor = Colors.green;
        statusLabel = 'Hoàn thành';
        break;
      case 'live':
        statusColor = Colors.red;
        statusLabel = 'Đang diễn ra';
        break;
      default:
        statusColor = Colors.blue;
        statusLabel = 'Đã lên lịch';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(fontWeight: FontWeight.bold, color: statusColor, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text(dateStr, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(statusLabel, style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
