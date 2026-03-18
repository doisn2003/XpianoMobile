import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_theme.dart';
import '../bloc/my_courses_bloc.dart';
import '../bloc/my_courses_event.dart';
import '../bloc/my_courses_state.dart';
import 'schedule_item_card.dart';

class ScheduleTab extends StatelessWidget {
  final MyCoursesLoaded state;

  const ScheduleTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== CALENDAR =====
          _buildCalendar(context),
          const SizedBox(height: 20),

          // ===== SELECTED DATE LABEL =====
          Center(
            child: Text(
              'Ngày ${state.selectedDate.day} tháng ${state.selectedDate.month}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ===== SESSION LIST =====
          if (state.sessionsForSelectedDate.isEmpty)
            _buildEmptySessionState()
          else
            ...state.sessionsForSelectedDate.map(
              (session) {
                // Tìm khóa học tương ứng
                final course = state.courses.firstWhere(
                  (c) => c.id == session.courseId,
                  orElse: () => state.courses.first, // Vẫn trả về course object đúng kiểu
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ScheduleItemCard(
                    session: session,
                    course: course,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptySessionState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.event_available, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Không có lịch học ngày này',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // ===== CALENDAR BUILDER =====
  Widget _buildCalendar(BuildContext context) {
    final displayed = state.displayedMonth;
    final year = displayed.year;
    final month = displayed.month;

    // Ngày đầu & cuối tháng
    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // weekday: 1=Mon...7=Sun → offset cho grid (0=CN)
    int startWeekday = firstDayOfMonth.weekday % 7; // CN=0, T2=1...T7=6

    // Tên tháng tiếng Việt
    const monthNames = [
      '', 'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4',
      'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8',
      'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12',
    ];

    // Tìm ngày có session trong tháng này
    final sessionDays = _getSessionDaysInMonth(year, month);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.dividerColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ==== HEADER: < Tháng X, năm Y > ====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: AppTheme.textPrimary),
                  onPressed: () {
                    context.read<MyCoursesBloc>().add(
                          ChangeMonth(DateTime(year, month - 1)),
                        );
                  },
                ),
                Text(
                  '${monthNames[month]}, $year',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: AppTheme.textPrimary),
                  onPressed: () {
                    context.read<MyCoursesBloc>().add(
                          ChangeMonth(DateTime(year, month + 1)),
                        );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ==== WEEKDAY HEADER: CN T2 T3 T4 T5 T6 T7 ====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _WeekdayLabel('CN'),
                _WeekdayLabel('T2'),
                _WeekdayLabel('T3'),
                _WeekdayLabel('T4'),
                _WeekdayLabel('T5'),
                _WeekdayLabel('T6'),
                _WeekdayLabel('T7'),
              ],
            ),
            const SizedBox(height: 8),

            // ==== GRID NGÀY ====
            _buildDayGrid(
              context,
              daysInMonth: daysInMonth,
              startWeekday: startWeekday,
              sessionDays: sessionDays,
              year: year,
              month: month,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayGrid(
    BuildContext context, {
    required int daysInMonth,
    required int startWeekday,
    required Set<int> sessionDays,
    required int year,
    required int month,
  }) {
    final today = DateTime.now();
    final cells = <Widget>[];

    // Ô trống đầu tháng
    for (int i = 0; i < startWeekday; i++) {
      cells.add(const SizedBox.shrink());
    }

    // Các ngày trong tháng
    for (int day = 1; day <= daysInMonth; day++) {
      final isSelected = state.selectedDate.year == year &&
          state.selectedDate.month == month &&
          state.selectedDate.day == day;

      final isToday = today.year == year && today.month == month && today.day == day;

      final hasSession = sessionDays.contains(day);

      cells.add(
        GestureDetector(
          onTap: () {
            context.read<MyCoursesBloc>().add(SelectDate(DateTime(year, month, day)));
          },
          child: _DayCell(
            day: day,
            isSelected: isSelected,
            isToday: isToday,
            hasSession: hasSession,
          ),
        ),
      );
    }

    // Sắp xếp vào grid 7 cột
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1,
      children: cells,
    );
  }

  /// Tìm tất cả ngày trong tháng có session
  Set<int> _getSessionDaysInMonth(int year, int month) {
    final days = <int>{};
    for (final session in state.allSessions) {
      try {
        final dt = DateTime.parse(session.scheduledAt);
        if (dt.year == year && dt.month == month) {
          days.add(dt.day);
        }
      } catch (_) {}
    }
    return days;
  }
}

// ==== SUB-WIDGETS ====

class _WeekdayLabel extends StatelessWidget {
  final String label;
  const _WeekdayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isSelected;
  final bool isToday;
  final bool hasSession;

  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.hasSession,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? AppTheme.primaryGold
                : isToday
                    ? AppTheme.primaryGoldLight.withOpacity(0.4)
                    : Colors.transparent,
          ),
          alignment: Alignment.center,
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : isToday
                      ? AppTheme.primaryGoldDark
                      : AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 2),
        // Chấm xanh nếu có session
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasSession ? Colors.blue : Colors.transparent,
          ),
        ),
      ],
    );
  }
}
