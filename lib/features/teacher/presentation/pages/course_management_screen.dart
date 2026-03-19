import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../../explore/data/models/course_model.dart';
import '../bloc/teacher_course_bloc.dart';
import '../bloc/teacher_course_event.dart';
import '../bloc/teacher_course_state.dart';
import '../widgets/create_course_bottom_sheet.dart';
import 'package:intl/intl.dart';

/// Màn hình Quản lý khóa học (CMS) dành cho giáo viên.
class CourseManagementScreen extends StatelessWidget {
  const CourseManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          TeacherCourseBloc(repository: sl())..add(LoadTeacherCourses()),
      child: const _CourseManagementBody(),
    );
  }
}

class _CourseManagementBody extends StatelessWidget {
  const _CourseManagementBody();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý khóa học'),
          bottom: TabBar(
            labelColor: AppTheme.primaryGoldDark,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primaryGold,
            tabs: const [
              Tab(text: 'Khóa học'),
              Tab(text: 'Lớp học'),
            ],
          ),
        ),
        body: SafeArea(
          bottom: true,
          child: TabBarView(
            children: [
              _CoursesTab(),
              _ClassroomComingSoon(),
            ],
          ),
        ),
      ),
    );
  }
}

// ==============================================================
// TAB 1: KHÓA HỌC
// ==============================================================

class _CoursesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeacherCourseBloc, TeacherCourseState>(
      listener: (context, state) {
        if (state is TeacherCourseActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is TeacherCourseError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is TeacherCourseLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<CourseModel> courses = [];
        if (state is TeacherCourseLoaded) courses = state.courses;
        if (state is TeacherCourseActionLoading) courses = state.courses;
        if (state is TeacherCourseActionSuccess) courses = state.courses;
        if (state is TeacherCourseError) courses = state.courses;

        return Stack(
          children: [
            if (courses.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school_outlined,
                        size: 56, color: AppTheme.textSecondary.withOpacity(0.4)),
                    const SizedBox(height: 12),
                    const Text('Chưa có khóa học nào',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 15)),
                    const SizedBox(height: 4),
                    const Text('Nhấn nút + để tạo khóa học đầu tiên',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13)),
                  ],
                ),
              )
            else
              RefreshIndicator(
                onRefresh: () async {
                  context
                      .read<TeacherCourseBloc>()
                      .add(LoadTeacherCourses());
                },
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: courses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _CourseCard(course: courses[index]),
                ),
              ),

            // FAB
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: AppTheme.primaryGold,
                foregroundColor: Colors.white,
                onPressed: () => _showCreateCourseDialog(context),
                child: const Icon(Icons.add),
              ),
            ),

            // Loading overlay for actions
            if (state is TeacherCourseActionLoading)
              Container(
                color: Colors.black12,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }

  void _showCreateCourseDialog(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: parentContext.read<TeacherCourseBloc>(),
        child: const CreateCourseBottomSheet(editCourse: null),
      ),
    );
  }
}

// ==============================================================
// COURSE CARD
// ==============================================================

class _CourseCard extends StatelessWidget {
  final CourseModel course;
  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final isDraft = course.status == 'draft';
    final priceFmt = NumberFormat.currency(
        locale: 'vi_VN', symbol: 'VNĐ', decimalDigits: 0);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDraft
              ? AppTheme.primaryGold.withOpacity(0.5)
              : AppTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Expanded(
                  child: Text(
                    course.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _StatusChip(status: course.status),
              ],
            ),
            const SizedBox(height: 8),
            // Info row
            Row(
              children: [
                _InfoTag(
                    icon: Icons.calendar_today,
                    text: '${course.durationWeeks} tuần'),
                const SizedBox(width: 12),
                _InfoTag(
                    icon: Icons.people,
                    text: 'Tối đa ${course.maxStudents} HV'),
                const SizedBox(width: 12),
                _InfoTag(
                    icon: Icons.monetization_on,
                    text: priceFmt.format(course.price)),
              ],
            ),
            const SizedBox(height: 10),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isDraft) ...[
                  IconButton(
                    onPressed: () => _confirmDelete(context, course.id),
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    tooltip: 'Xóa',
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        _showEditCourseDialog(context, course),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Sửa'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryGoldDark),
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton.icon(
                    onPressed: () => _confirmPublish(context, course.id),
                    icon: const Icon(Icons.publish, size: 16),
                    label: const Text('Xuất bản'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGold,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String courseId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa khóa học?'),
        content: const Text(
            'Bạn có chắc chắn muốn xóa bản nháp khóa học này không? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<TeacherCourseBloc>()
                  .add(DeleteTeacherCourse(courseId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _confirmPublish(BuildContext context, String courseId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xuất bản khóa học?'),
        content: const Text(
            'Sau khi xuất bản, các buổi học sẽ được tạo tự động và không thể chỉnh sửa khóa học nữa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<TeacherCourseBloc>()
                  .add(PublishTeacherCourse(courseId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGold,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xuất bản'),
          ),
        ],
      ),
    );
  }

  void _showEditCourseDialog(BuildContext parentContext, CourseModel course) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: parentContext.read<TeacherCourseBloc>(),
        child: CreateCourseBottomSheet(editCourse: course),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    switch (status) {
      case 'published':
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        label = 'Đã xuất bản';
        break;
      case 'draft':
        bg = const Color(0xFFFFF8E1);
        fg = AppTheme.primaryGoldDark;
        label = 'Bản nháp';
        break;
      default:
        bg = AppTheme.bgCreamDarker;
        fg = AppTheme.textSecondary;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style:
              TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

class _InfoTag extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoTag({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(
                fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }
}

// ==============================================================


// ==============================================================
// TAB 2: LỚP HỌC (Coming Soon)
// ==============================================================

class _ClassroomComingSoon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction_rounded,
              size: 56, color: AppTheme.primaryGold.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            'Tính năng Lớp học',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          const Text(
            'Sẽ được phát triển trong phiên bản tiếp theo',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
