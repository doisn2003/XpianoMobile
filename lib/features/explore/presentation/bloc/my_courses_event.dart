abstract class MyCoursesEvent {}

class LoadMyCourses extends MyCoursesEvent {
  final bool isTeacher;
  LoadMyCourses({required this.isTeacher});
}
