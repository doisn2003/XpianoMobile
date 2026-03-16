import '../../domain/entities/course.dart';

abstract class CourseListState {}

class CourseListInitial extends CourseListState {}

class CourseListLoading extends CourseListState {}

class CourseListLoaded extends CourseListState {
  final List<Course> courses;
  final List<Course> allCourses;
  final String searchQuery;
  final bool hasMore;

  CourseListLoaded({
    required this.courses,
    required this.allCourses,
    this.searchQuery = '',
    this.hasMore = false,
  });
}

class CourseListError extends CourseListState {
  final String message;
  CourseListError(this.message);
}
