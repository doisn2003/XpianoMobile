import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../domain/entities/assignment.dart';
import 'assignment_card.dart';

class AssignmentTab extends StatelessWidget {
  final List<Assignment> assignments;

  const AssignmentTab({super.key, required this.assignments});

  @override
  Widget build(BuildContext context) {
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
