import 'package:equatable/equatable.dart';

abstract class TeacherCourseEvent extends Equatable {
  const TeacherCourseEvent();

  @override
  List<Object?> get props => [];
}

class LoadTeacherCourses extends TeacherCourseEvent {}

class CreateTeacherCourse extends TeacherCourseEvent {
  final Map<String, dynamic> body;
  const CreateTeacherCourse(this.body);

  @override
  List<Object?> get props => [body];
}

class UpdateTeacherCourse extends TeacherCourseEvent {
  final String courseId;
  final Map<String, dynamic> body;
  const UpdateTeacherCourse(this.courseId, this.body);

  @override
  List<Object?> get props => [courseId, body];
}

class PublishTeacherCourse extends TeacherCourseEvent {
  final String courseId;
  const PublishTeacherCourse(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

class DeleteTeacherCourse extends TeacherCourseEvent {
  final String courseId;
  const DeleteTeacherCourse(this.courseId);

  @override
  List<Object?> get props => [courseId];
}
