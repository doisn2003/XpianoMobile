import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/course_repository.dart';
import 'my_courses_event.dart';
import 'my_courses_state.dart';

class MyCoursesBloc extends Bloc<MyCoursesEvent, MyCoursesState> {
  final CourseRepository courseRepository;

  MyCoursesBloc({required this.courseRepository}) : super(MyCoursesInitial()) {
    on<LoadMyCourses>(_onLoad);
  }

  Future<void> _onLoad(LoadMyCourses event, Emitter<MyCoursesState> emit) async {
    emit(MyCoursesLoading());

    final result = event.isTeacher
        ? await courseRepository.getMyTeachingCourses()
        : await courseRepository.getMyEnrolledCourses();

    result.fold(
      (failure) => emit(MyCoursesError(failure.message)),
      (courses) => emit(MyCoursesLoaded(courses: courses, isTeacher: event.isTeacher)),
    );
  }
}
