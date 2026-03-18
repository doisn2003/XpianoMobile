import 'package:equatable/equatable.dart';

class Assignment extends Equatable {
  final String id;
  final String courseTitle;
  final String title;
  final String? description;
  final DateTime dueDate;
  final String status; // pending, submitted, graded

  const Assignment({
    required this.id,
    required this.courseTitle,
    required this.title,
    this.description,
    required this.dueDate,
    this.status = 'pending',
  });

  @override
  List<Object?> get props => [id, courseTitle, title, dueDate, status];
}
