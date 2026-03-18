import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../injection_container.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/my_courses_bloc.dart';
import '../bloc/my_courses_event.dart';
import '../bloc/my_courses_state.dart';
import '../widgets/assignment_tab.dart';
import '../widgets/notification_tab.dart';
import '../widgets/schedule_tab.dart';

class MyCoursesScreen extends StatelessWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final isTeacher = authState is AuthAuthenticated && authState.user.isTeacher;

    return BlocProvider(
      create: (_) => MyCoursesBloc(repository: sl())
        ..add(LoadMyCourses(isTeacher: isTeacher)),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Khóa học của tôi'),
            bottom: TabBar(
              labelColor: AppTheme.primaryGoldDark,
              unselectedLabelColor: AppTheme.textSecondary,
              indicatorColor: AppTheme.primaryGold,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              tabs: const [
                Tab(text: 'Thời khóa biểu'),
                Tab(text: 'Bài tập'),
                Tab(text: 'Thông báo'),
              ],
            ),
          ),
          body: SafeArea(
            child: BlocBuilder<MyCoursesBloc, MyCoursesState>(
              builder: (context, state) {
                if (state is MyCoursesLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryGold),
                  );
                }

                if (state is MyCoursesError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'Không thể tải dữ liệu',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red.shade400),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<MyCoursesBloc>().add(LoadMyCourses(isTeacher: isTeacher));
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is MyCoursesLoaded) {
                  return TabBarView(
                    children: [
                      ScheduleTab(state: state),
                      AssignmentTab(assignments: state.assignments),
                      NotificationTab(notifications: state.notifications),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }
}
