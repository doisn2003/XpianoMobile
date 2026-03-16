import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/course_repository.dart';
import 'course_detail_event.dart';
import 'course_detail_state.dart';

class CourseDetailBloc extends Bloc<CourseDetailEvent, CourseDetailState> {
  final CourseRepository courseRepository;

  CourseDetailBloc({required this.courseRepository}) : super(CourseDetailInitial()) {
    on<LoadCourseDetail>(_onLoadDetail);
  }

  Future<void> _onLoadDetail(LoadCourseDetail event, Emitter<CourseDetailState> emit) async {
    emit(CourseDetailLoading());
    final result = await courseRepository.getCourseDetail(event.courseId);
    result.fold(
      (failure) => emit(CourseDetailError(failure.message)),
      (course) => emit(CourseDetailLoaded(course)),
    );
  }
}
