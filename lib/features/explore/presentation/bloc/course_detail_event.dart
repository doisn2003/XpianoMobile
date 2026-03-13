abstract class CourseDetailEvent {}

class LoadCourseDetail extends CourseDetailEvent {
  final String courseId;
  LoadCourseDetail(this.courseId);
}
