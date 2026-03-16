import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/course_repository.dart';
import 'course_order_event.dart';
import 'course_order_state.dart';

class CourseOrderBloc extends Bloc<CourseOrderEvent, CourseOrderState> {
  final CourseRepository courseRepository;

  CourseOrderBloc({required this.courseRepository}) : super(CourseOrderInitial()) {
    on<CreateCourseOrder>(_onCreateOrder);
  }

  Future<void> _onCreateOrder(CreateCourseOrder event, Emitter<CourseOrderState> emit) async {
    emit(CourseOrderLoading());
    final result = await courseRepository.createCourseOrder(
      courseId: event.courseId,
      paymentMethod: event.paymentMethod,
    );
    result.fold(
      (failure) => emit(CourseOrderError(failure.message)),
      (data) => emit(CourseOrderSuccess(data)),
    );
  }
}
