import 'package:equatable/equatable.dart';

class CourseNotification extends Equatable {
  final String id;
  final String courseTitle;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  const CourseNotification({
    required this.id,
    required this.courseTitle,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  @override
  List<Object?> get props => [id, courseTitle, message, createdAt, isRead];
}
