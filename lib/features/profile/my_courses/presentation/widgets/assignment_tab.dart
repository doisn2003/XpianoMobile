import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_theme.dart';
import '../bloc/my_courses_bloc.dart';
import '../bloc/my_courses_event.dart';
import '../bloc/my_courses_state.dart';
import 'assignment_card.dart';

class AssignmentTab extends StatefulWidget {
  final MyCoursesLoaded state;

  const AssignmentTab({super.key, required this.state});

  @override
  State<AssignmentTab> createState() => _AssignmentTabState();
}

class _AssignmentTabState extends State<AssignmentTab> {
  @override
  void initState() {
    super.initState();
    if (!widget.state.hasLoadedAssignments && !widget.state.isLoadingAssignments) {
      context.read<MyCoursesBloc>().add(LoadAssignments());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state.isLoadingAssignments) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
    }

    final assignments = widget.state.assignments;
    if (assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'Chưa có bài tập nào',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: assignments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return AssignmentCard(assignment: assignments[index]);
      },
    );
  }
}
