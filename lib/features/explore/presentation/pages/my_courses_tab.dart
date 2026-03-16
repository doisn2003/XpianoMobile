import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/repositories/course_repository.dart';
import '../bloc/my_courses_bloc.dart';
import '../bloc/my_courses_event.dart';
import '../bloc/my_courses_state.dart';
import '../widgets/course_card_widget.dart';
import 'course_schedule_detail_screen.dart';

class MyCoursesTab extends StatelessWidget {
  const MyCoursesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isTeacher = authState is AuthAuthenticated && authState.user.isTeacher;

    return BlocProvider<MyCoursesBloc>(
      create: (_) => MyCoursesBloc(courseRepository: di.sl<CourseRepository>())
        ..add(LoadMyCourses(isTeacher: isTeacher)),
      child: _MyCoursesView(isTeacher: isTeacher),
    );
  }
}

class _MyCoursesView extends StatelessWidget {
  final bool isTeacher;

  const _MyCoursesView({required this.isTeacher});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppTheme.cardWhite,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          width: double.infinity,
          child: Text(
            isTeacher ? 'Khóa học đang dạy' : 'Khóa học đã đăng ký',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
        ),
        Expanded(
          child: BlocBuilder<MyCoursesBloc, MyCoursesState>(
            builder: (context, state) {
              if (state is MyCoursesLoading) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
              }

              if (state is MyCoursesError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                      const SizedBox(height: 12),
                      Text(state.message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<MyCoursesBloc>().add(LoadMyCourses(isTeacher: isTeacher)),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              if (state is MyCoursesLoaded) {
                if (state.courses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school_outlined, size: 64, color: AppTheme.textSecondary.withOpacity(0.3)),
                        const SizedBox(height: 12),
                        Text(
                          isTeacher ? 'Bạn chưa tạo khóa học nào' : 'Bạn chưa đăng ký khóa học nào',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppTheme.primaryGold,
                  onRefresh: () async {
                    context.read<MyCoursesBloc>().add(LoadMyCourses(isTeacher: isTeacher));
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.58,
                    ),
                    itemCount: state.courses.length,
                    itemBuilder: (context, index) {
                      final course = state.courses[index];
                      return CourseCardWidget(
                        course: course,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CourseScheduleDetailScreen(
                                courseId: course.id,
                                isTeacher: isTeacher,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
