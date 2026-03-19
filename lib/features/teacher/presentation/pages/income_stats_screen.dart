import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../bloc/teacher_stats_bloc.dart';
import '../bloc/teacher_stats_event_state.dart';
import '../widgets/revenue_chart_widget.dart';

/// Màn hình Thống kê Thu nhập dành cho giáo viên.
class IncomeStatsScreen extends StatelessWidget {
  const IncomeStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          TeacherStatsBloc(repository: sl())..add(LoadTeacherStats()),
      child: const _IncomeStatsBody(),
    );
  }
}

class _IncomeStatsBody extends StatelessWidget {
  const _IncomeStatsBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê thu nhập')),
      body: BlocBuilder<TeacherStatsBloc, TeacherStatsState>(
        builder: (context, state) {
          if (state is TeacherStatsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TeacherStatsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: Colors.red.shade400),
                  const SizedBox(height: 12),
                  Text(state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<TeacherStatsBloc>()
                        .add(LoadTeacherStats()),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state is TeacherStatsLoaded) {
            final stats = state.stats;
            final revenueFmt = NumberFormat.currency(
              locale: 'vi_VN',
              symbol: 'VNĐ',
              decimalDigits: 0,
            );

            return RefreshIndicator(
              onRefresh: () async {
                context.read<TeacherStatsBloc>().add(LoadTeacherStats());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Summary cards
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.school,
                          label: 'Khóa học',
                          value: stats.totalCourses.toString(),
                          color: const Color(0xFF4A90D9),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.people,
                          label: 'Học viên',
                          value: stats.totalStudents.toString(),
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _StatCard(
                    icon: Icons.monetization_on,
                    label: 'Tổng doanh thu',
                    value: revenueFmt.format(stats.totalRevenue),
                    color: AppTheme.primaryGold,
                    fullWidth: true,
                  ),
                  const SizedBox(height: 20),
                  // Chart
                  RevenueChartWidget(data: stats.chartData),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool fullWidth;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: color.withOpacity(0.25), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fullWidth ? 18 : 16,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
