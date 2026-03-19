import 'package:equatable/equatable.dart';
import '../../../explore/data/models/course_model.dart';

abstract class TeacherCourseState extends Equatable {
  const TeacherCourseState();

  @override
  List<Object?> get props => [];
}

class TeacherCourseInitial extends TeacherCourseState {}

class TeacherCourseLoading extends TeacherCourseState {}

class TeacherCourseLoaded extends TeacherCourseState {
  final List<CourseModel> courses;
  const TeacherCourseLoaded(this.courses);

  @override
  List<Object?> get props => [courses];
}

class TeacherCourseActionLoading extends TeacherCourseState {
  /// Lưu lại danh sách trước đó để UI không mất data.
  final List<CourseModel> courses;
  const TeacherCourseActionLoading(this.courses);

  @override
  List<Object?> get props => [courses];
}

class TeacherCourseActionSuccess extends TeacherCourseState {
  final String message;
  final List<CourseModel> courses;
  const TeacherCourseActionSuccess(this.message, this.courses);

  @override
  List<Object?> get props => [message, courses];
}

class TeacherCourseError extends TeacherCourseState {
  final String message;
  final List<CourseModel> courses;
  const TeacherCourseError(this.message, {this.courses = const []});

  @override
  List<Object?> get props => [message, courses];
}
