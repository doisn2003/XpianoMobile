abstract class CourseOrderEvent {}

class CreateCourseOrder extends CourseOrderEvent {
  final String courseId;
  final String paymentMethod;

  CreateCourseOrder({required this.courseId, required this.paymentMethod});
}
