import '../../domain/entities/course.dart';

abstract class MyCoursesState {}

class MyCoursesInitial extends MyCoursesState {}

class MyCoursesLoading extends MyCoursesState {}

class MyCoursesLoaded extends MyCoursesState {
  final List<Course> courses;
  final bool isTeacher;

  MyCoursesLoaded({required this.courses, required this.isTeacher});
}

class MyCoursesError extends MyCoursesState {
  final String message;
  MyCoursesError(this.message);
}
