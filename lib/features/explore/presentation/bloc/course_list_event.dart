abstract class CourseListEvent {}

class LoadCourses extends CourseListEvent {}

class LoadMoreCourses extends CourseListEvent {}

class SearchCourses extends CourseListEvent {
  final String query;
  SearchCourses(this.query);
}
