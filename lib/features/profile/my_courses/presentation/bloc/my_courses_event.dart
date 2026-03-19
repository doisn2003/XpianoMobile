import 'package:equatable/equatable.dart';

abstract class MyCoursesEvent extends Equatable {
  const MyCoursesEvent();

  @override
  List<Object?> get props => [];
}

/// Load tất cả dữ liệu: courses, sessions, assignments, notifications
class LoadMyCourses extends MyCoursesEvent {
  final bool isTeacher;

  const LoadMyCourses({required this.isTeacher});

  @override
  List<Object?> get props => [isTeacher];
}

/// Chọn ngày trên lịch
class SelectDate extends MyCoursesEvent {
  final DateTime date;

  const SelectDate(this.date);

  @override
  List<Object?> get props => [date];
}

/// Chuyển tháng trên lịch
class ChangeMonth extends MyCoursesEvent {
  final DateTime month;

  const ChangeMonth(this.month);

  @override
  List<Object?> get props => [month];
}

class LoadAssignments extends MyCoursesEvent {}

class LoadNotifications extends MyCoursesEvent {}
