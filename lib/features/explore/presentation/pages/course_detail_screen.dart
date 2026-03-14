import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/widgets/auth_required_dialog.dart';
import '../../domain/repositories/course_repository.dart';
import '../bloc/course_detail_bloc.dart';
import '../bloc/course_detail_event.dart';
import '../bloc/course_detail_state.dart';
import '../widgets/course_media_header.dart';
import '../widgets/course_order_sheet.dart';

class CourseDetailScreen extends StatelessWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CourseDetailBloc>(
      create: (_) => CourseDetailBloc(courseRepository: di.sl<CourseRepository>())..add(LoadCourseDetail(courseId)),
      child: const _CourseDetailView(),
    );
  }
}

class _CourseDetailView extends StatelessWidget {
  const _CourseDetailView();

  Future<bool> _ensureAuth(BuildContext context) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) return true;
    return await AuthRequiredDialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      body: BlocBuilder<CourseDetailBloc, CourseDetailState>(
        builder: (context, state) {
          if (state is CourseDetailLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
          }

          if (state is CourseDetailError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(state.message, style: const TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Quay lại'),
                  ),
                ],
              ),
            );
          }

          if (state is CourseDetailLoaded) {
            final course = state.course;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 240,
                  pinned: true,
                  backgroundColor: AppTheme.cardWhite,
                  leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: AppTheme.textPrimary, size: 20),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: CourseMediaHeader(
                      thumbnailUrl: course.thumbnailUrl,
                      coverUrl: course.coverUrl,
                      demoVideoUrl: course.demoVideoUrl,
                      height: 240 + MediaQuery.of(context).padding.top,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status badge row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGold.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                course.isOnline ? 'Online' : 'Offline',
                                style: const TextStyle(color: AppTheme.primaryGoldDark, fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.people, size: 16, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '${course.enrolledCount}/${course.maxStudents} học viên',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Title
                        Text(
                          course.title,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 12),

                        // Teacher info
                        if (course.teacher != null) ...[
                          Row(
                            children: [
                              _buildTeacherAvatar(course.teacher!),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(course.teacher!.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                  const Text('Giáo viên', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Info cards
                        Row(
                          children: [
                            Expanded(child: _buildInfoCard('Thời lượng', '${course.durationWeeks} tuần', Icons.schedule)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildInfoCard('Tần suất', '${course.sessionsPerWeek} buổi/tuần', Icons.repeat)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                'Học phí',
                                course.price > 0 ? currencyFormat.format(course.price) : 'Miễn phí',
                                Icons.payments,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoCard(
                                'Hình thức',
                                course.isOnline ? 'Trực tuyến' : (course.location ?? 'Tại chỗ'),
                                course.isOnline ? Icons.videocam : Icons.location_on,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Description
                        if (course.description != null && course.description!.isNotEmpty) ...[
                          const Text('Mô tả khóa học', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                          const SizedBox(height: 8),
                          Text(
                            course.description!,
                            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.6),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Schedule info
                        if (course.schedule.isNotEmpty) ...[
                          const Text('Lịch học', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                          const SizedBox(height: 8),
                          ...course.schedule.map((sch) {
                            final dayNames = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
                            final dayIndex = int.tryParse(sch['day_of_week']?.toString() ?? '') ?? 0;
                            final dayName = dayIndex < dayNames.length ? dayNames[dayIndex] : 'N/A';
                            final time = sch['time']?.toString() ?? '';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  const Icon(Icons.event, size: 16, color: AppTheme.primaryGold),
                                  const SizedBox(width: 8),
                                  Text('$dayName - $time', style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 32),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),

      // Bottom CTA
      bottomNavigationBar: BlocBuilder<CourseDetailBloc, CourseDetailState>(
        builder: (context, state) {
          if (state is! CourseDetailLoaded) return const SizedBox.shrink();
          final course = state.course;

          return Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -2)),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      final authed = await _ensureAuth(context);
                      if (authed && context.mounted) {
                        CourseOrderSheet.show(context, course: course);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('ĐĂNG KÝ KHÓA HỌC', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTeacherAvatar(dynamic teacher) {
    final avatarUrl = ImageUtils.optimizedAvatar(teacher.avatarUrl);
    if (avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundColor: AppTheme.primaryGold.withOpacity(0.15),
        backgroundImage: CachedNetworkImageProvider(avatarUrl),
      );
    }
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppTheme.primaryGold.withOpacity(0.15),
      child: Text(
        teacher.fullName.isNotEmpty ? teacher.fullName[0].toUpperCase() : '?',
        style: const TextStyle(color: AppTheme.primaryGoldDark, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.primaryGold),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryGoldDark)),
        ],
      ),
    );
  }
}
