import 'package:equatable/equatable.dart';

import '../../../../explore/domain/entities/course.dart';
import '../../domain/entities/assignment.dart';
import '../../domain/entities/course_notification.dart';

abstract class MyCoursesState extends Equatable {
  const MyCoursesState();

  @override
  List<Object?> get props => [];
}

class MyCoursesInitial extends MyCoursesState {}

class MyCoursesLoading extends MyCoursesState {}

class MyCoursesLoaded extends MyCoursesState {
  final List<Course> courses;
  final List<CourseSession> allSessions;
  final DateTime selectedDate;
  final DateTime displayedMonth;
  final List<CourseSession> sessionsForSelectedDate;
  final List<Assignment> assignments;
  final List<CourseNotification> notifications;

  const MyCoursesLoaded({
    required this.courses,
    required this.allSessions,
    required this.selectedDate,
    required this.displayedMonth,
    required this.sessionsForSelectedDate,
    required this.assignments,
    required this.notifications,
  });

  MyCoursesLoaded copyWith({
    List<Course>? courses,
    List<CourseSession>? allSessions,
    DateTime? selectedDate,
    DateTime? displayedMonth,
    List<CourseSession>? sessionsForSelectedDate,
    List<Assignment>? assignments,
    List<CourseNotification>? notifications,
  }) {
    return MyCoursesLoaded(
      courses: courses ?? this.courses,
      allSessions: allSessions ?? this.allSessions,
      selectedDate: selectedDate ?? this.selectedDate,
      displayedMonth: displayedMonth ?? this.displayedMonth,
      sessionsForSelectedDate: sessionsForSelectedDate ?? this.sessionsForSelectedDate,
      assignments: assignments ?? this.assignments,
      notifications: notifications ?? this.notifications,
    );
  }

  @override
  List<Object?> get props => [
        courses,
        allSessions,
        selectedDate,
        displayedMonth,
        sessionsForSelectedDate,
        assignments,
        notifications,
      ];
}

class MyCoursesError extends MyCoursesState {
  final String message;

  const MyCoursesError(this.message);

  @override
  List<Object?> get props => [message];
}
