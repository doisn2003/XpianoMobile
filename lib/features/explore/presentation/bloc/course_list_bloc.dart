import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/course_repository.dart';
import 'course_list_event.dart';
import 'course_list_state.dart';

class CourseListBloc extends Bloc<CourseListEvent, CourseListState> {
  final CourseRepository courseRepository;

  CourseListBloc({required this.courseRepository}) : super(CourseListInitial()) {
    on<LoadCourses>(_onLoadCourses);
    on<SearchCourses>(_onSearchCourses);
  }

  Future<void> _onLoadCourses(LoadCourses event, Emitter<CourseListState> emit) async {
    emit(CourseListLoading());
    final result = await courseRepository.getPublicCourses();
    result.fold(
      (failure) => emit(CourseListError(failure.message)),
      (courses) => emit(CourseListLoaded(
        courses: courses,
        allCourses: courses,
      )),
    );
  }

  void _onSearchCourses(SearchCourses event, Emitter<CourseListState> emit) {
    final current = state;
    if (current is! CourseListLoaded) return;

    final query = event.query.toLowerCase().trim();
    if (query.isEmpty) {
      emit(CourseListLoaded(
        courses: current.allCourses,
        allCourses: current.allCourses,
      ));
      return;
    }

    final filtered = current.allCourses.where((c) {
      return c.title.toLowerCase().contains(query) ||
          (c.description?.toLowerCase().contains(query) ?? false) ||
          (c.teacher?.fullName.toLowerCase().contains(query) ?? false);
    }).toList();

    emit(CourseListLoaded(
      courses: filtered,
      allCourses: current.allCourses,
      searchQuery: event.query,
    ));
  }
}
