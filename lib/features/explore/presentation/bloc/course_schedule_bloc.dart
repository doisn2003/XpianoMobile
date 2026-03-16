import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/course.dart';
import '../../domain/repositories/course_repository.dart';
import 'course_schedule_event.dart';
import 'course_schedule_state.dart';

class CourseScheduleBloc extends Bloc<CourseScheduleEvent, CourseScheduleState> {
  final CourseRepository courseRepository;

  CourseScheduleBloc({required this.courseRepository}) : super(CourseScheduleInitial()) {
    on<LoadCourseSchedule>(_onLoad);
  }

  Future<void> _onLoad(LoadCourseSchedule event, Emitter<CourseScheduleState> emit) async {
    emit(CourseScheduleLoading());

    final courseResult = await courseRepository.getCourseDetail(event.courseId);

    await courseResult.fold(
      (failure) async => emit(CourseScheduleError(failure.message)),
      (course) async {
        final sessionsResult = await courseRepository.getCourseSessions(event.courseId);
        final sessions = sessionsResult.getOrElse(() => <CourseSession>[]);

        List<CourseEnrollment> enrollments = [];
        if (event.isTeacher) {
          final enrollResult = await courseRepository.getCourseEnrollments(event.courseId);
          enrollments = enrollResult.getOrElse(() => <CourseEnrollment>[]);
        }

        emit(CourseScheduleLoaded(
          course: course,
          sessions: sessions,
          enrollments: enrollments,
          isTeacher: event.isTeacher,
        ));
      },
    );
  }
}
