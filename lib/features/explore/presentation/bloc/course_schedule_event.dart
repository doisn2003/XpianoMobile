abstract class CourseScheduleEvent {}

class LoadCourseSchedule extends CourseScheduleEvent {
  final String courseId;
  final bool isTeacher;
  LoadCourseSchedule({required this.courseId, required this.isTeacher});
}
