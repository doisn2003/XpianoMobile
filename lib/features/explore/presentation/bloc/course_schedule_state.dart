import '../../domain/entities/course.dart';

abstract class CourseScheduleState {}

class CourseScheduleInitial extends CourseScheduleState {}

class CourseScheduleLoading extends CourseScheduleState {}

class CourseScheduleLoaded extends CourseScheduleState {
  final Course course;
  final List<CourseSession> sessions;
  final List<CourseEnrollment> enrollments;
  final bool isTeacher;

  CourseScheduleLoaded({
    required this.course,
    required this.sessions,
    required this.enrollments,
    required this.isTeacher,
  });

  int get completedSessions => sessions.where((s) => s.status == 'ended').length;
  int get totalSessions => sessions.length;
}

class CourseScheduleError extends CourseScheduleState {
  final String message;
  CourseScheduleError(this.message);
}
