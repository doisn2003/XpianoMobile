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
  final bool isLoadingAssignments;
  final bool isLoadingNotifications;
  final bool hasLoadedAssignments;
  final bool hasLoadedNotifications;

  const MyCoursesLoaded({
    required this.courses,
    required this.allSessions,
    required this.selectedDate,
    required this.displayedMonth,
    required this.sessionsForSelectedDate,
    this.assignments = const [],
    this.notifications = const [],
    this.isLoadingAssignments = false,
    this.isLoadingNotifications = false,
    this.hasLoadedAssignments = false,
    this.hasLoadedNotifications = false,
  });

  MyCoursesLoaded copyWith({
    List<Course>? courses,
    List<CourseSession>? allSessions,
    DateTime? selectedDate,
    DateTime? displayedMonth,
    List<CourseSession>? sessionsForSelectedDate,
    List<Assignment>? assignments,
    List<CourseNotification>? notifications,
    bool? isLoadingAssignments,
    bool? isLoadingNotifications,
    bool? hasLoadedAssignments,
    bool? hasLoadedNotifications,
  }) {
    return MyCoursesLoaded(
      courses: courses ?? this.courses,
      allSessions: allSessions ?? this.allSessions,
      selectedDate: selectedDate ?? this.selectedDate,
      displayedMonth: displayedMonth ?? this.displayedMonth,
      sessionsForSelectedDate: sessionsForSelectedDate ?? this.sessionsForSelectedDate,
      assignments: assignments ?? this.assignments,
      notifications: notifications ?? this.notifications,
      isLoadingAssignments: isLoadingAssignments ?? this.isLoadingAssignments,
      isLoadingNotifications: isLoadingNotifications ?? this.isLoadingNotifications,
      hasLoadedAssignments: hasLoadedAssignments ?? this.hasLoadedAssignments,
      hasLoadedNotifications: hasLoadedNotifications ?? this.hasLoadedNotifications,
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
        isLoadingAssignments,
        isLoadingNotifications,
        hasLoadedAssignments,
        hasLoadedNotifications,
      ];
}

class MyCoursesError extends MyCoursesState {
  final String message;

  const MyCoursesError(this.message);

  @override
  List<Object?> get props => [message];
}
