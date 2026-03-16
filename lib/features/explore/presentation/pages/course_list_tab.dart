import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/repositories/course_repository.dart';
import '../bloc/course_list_bloc.dart';
import '../bloc/course_list_event.dart';
import '../bloc/course_list_state.dart';
import '../widgets/course_card_widget.dart';
import 'course_detail_screen.dart';

class CourseListTab extends StatelessWidget {
  const CourseListTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CourseListBloc>(
      create: (_) => CourseListBloc(courseRepository: di.sl<CourseRepository>())..add(LoadCourses()),
      child: const _CourseListView(),
    );
  }
}

class _CourseListView extends StatefulWidget {
  const _CourseListView();

  @override
  State<_CourseListView> createState() => _CourseListViewState();
}

class _CourseListViewState extends State<_CourseListView> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Container(
          color: AppTheme.cardWhite,
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
          child: Row(
            children: [
              Expanded(
                child: _isSearching
                    ? TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: 'Tìm kiếm khóa học...',
                          hintStyle: TextStyle(color: AppTheme.textSecondary),
                          border: InputBorder.none,
                        ),
                        onChanged: (query) {
                          context.read<CourseListBloc>().add(SearchCourses(query));
                        },
                      )
                    : const Text(
                        'Chợ khóa học',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
              ),
              IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search, color: AppTheme.textPrimary),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                      context.read<CourseListBloc>().add(SearchCourses(''));
                    }
                  });
                },
              ),
            ],
          ),
        ),

        // Course grid
        Expanded(
          child: BlocBuilder<CourseListBloc, CourseListState>(
            builder: (context, state) {
              if (state is CourseListLoading) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
              }

              if (state is CourseListError) {
                return _buildErrorView(context, state.message);
              }

              if (state is CourseListLoaded) {
                if (state.courses.isEmpty) {
                  return _buildEmptyView();
                }

                return RefreshIndicator(
                  color: AppTheme.primaryGold,
                  onRefresh: () async {
                    context.read<CourseListBloc>().add(LoadCourses());
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
                              builder: (_) => CourseDetailScreen(courseId: course.id),
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

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<CourseListBloc>().add(LoadCourses()),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 64, color: AppTheme.textSecondary.withOpacity(0.3)),
          const SizedBox(height: 12),
          const Text('Chưa có khóa học nào', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
        ],
      ),
    );
  }
}
