import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../explore/domain/entities/course.dart';
import '../../domain/repositories/my_courses_repository.dart';
import 'my_courses_event.dart';
import 'my_courses_state.dart';
import '../../domain/entities/assignment.dart';
import '../../domain/entities/course_notification.dart';

class MyCoursesBloc extends Bloc<MyCoursesEvent, MyCoursesState> {
  final MyCoursesRepository repository;

  MyCoursesBloc({required this.repository}) : super(MyCoursesInitial()) {
    on<LoadMyCourses>(_onLoadMyCourses);
    on<SelectDate>(_onSelectDate);
    on<ChangeMonth>(_onChangeMonth);
    on<LoadAssignments>(_onLoadAssignments);
    on<LoadNotifications>(_onLoadNotifications);
  }

  Future<void> _onLoadMyCourses(
    LoadMyCourses event,
    Emitter<MyCoursesState> emit,
  ) async {
    emit(MyCoursesLoading());

    try {
      // 1. Lấy danh sách khóa học
      final coursesResult = await repository.getMyCourses(isTeacher: event.isTeacher);

      // Dùng pattern getOrElse thay vì fold async (fold + async callback không tương thích BLoC emit)
      if (coursesResult.isLeft()) {
        final failure = coursesResult.fold((l) => l, (r) => null);
        emit(MyCoursesError(failure?.message ?? 'Lỗi không xác định'));
        return;
      }

      final List<Course> courses = coursesResult.getOrElse(() => []);

      // 2. Lấy sessions cho tất cả courses
      List<CourseSession> allSessions = [];
      if (courses.isNotEmpty) {
        final courseIds = courses.map((c) => c.id).toList();
        final sessionsResult = await repository.getSessionsForCourses(courseIds);
        allSessions = sessionsResult.getOrElse(() => []);
      }

      // 3. Emit loaded state (only courses and sessions)
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      emit(MyCoursesLoaded(
        courses: courses,
        allSessions: allSessions,
        selectedDate: today,
        displayedMonth: DateTime(today.year, today.month),
        sessionsForSelectedDate: _filterSessionsByDate(allSessions, today),
      ));
    } catch (e) {
      emit(MyCoursesError('Đã xảy ra lỗi: ${e.toString()}'));
    }
  }

  void _onSelectDate(SelectDate event, Emitter<MyCoursesState> emit) {
    final currentState = state;
    if (currentState is MyCoursesLoaded) {
      emit(currentState.copyWith(
        selectedDate: event.date,
        sessionsForSelectedDate: _filterSessionsByDate(
          currentState.allSessions,
          event.date,
        ),
      ));
    }
  }

  void _onChangeMonth(ChangeMonth event, Emitter<MyCoursesState> emit) {
    final currentState = state;
    if (currentState is MyCoursesLoaded) {
      emit(currentState.copyWith(displayedMonth: event.month));
    }
  }

  Future<void> _onLoadAssignments(LoadAssignments event, Emitter<MyCoursesState> emit) async {
    if (state is MyCoursesLoaded) {
      final currentState = state as MyCoursesLoaded;
      if (currentState.hasLoadedAssignments || currentState.isLoadingAssignments) return;

      emit(currentState.copyWith(isLoadingAssignments: true));
      try {
        final assignments = await repository.getMockAssignments();
        emit((state as MyCoursesLoaded).copyWith(
          assignments: assignments,
          isLoadingAssignments: false,
          hasLoadedAssignments: true,
        ));
      } catch (e) {
        emit((state as MyCoursesLoaded).copyWith(isLoadingAssignments: false));
        print('[MyCoursesBloc] Load mock assignments error: $e');
      }
    }
  }

  Future<void> _onLoadNotifications(LoadNotifications event, Emitter<MyCoursesState> emit) async {
    if (state is MyCoursesLoaded) {
      final currentState = state as MyCoursesLoaded;
      if (currentState.hasLoadedNotifications || currentState.isLoadingNotifications) return;

      emit(currentState.copyWith(isLoadingNotifications: true));
      try {
        final notifications = await repository.getMockNotifications();
        emit((state as MyCoursesLoaded).copyWith(
          notifications: notifications,
          isLoadingNotifications: false,
          hasLoadedNotifications: true,
        ));
      } catch (e) {
        emit((state as MyCoursesLoaded).copyWith(isLoadingNotifications: false));
        print('[MyCoursesBloc] Load mock notifications error: $e');
      }
    }
  }

  /// Lọc sessions theo ngày (so sánh year-month-day)
  List<CourseSession> _filterSessionsByDate(
    List<CourseSession> sessions,
    DateTime date,
  ) {
    return sessions.where((session) {
      try {
        final sessionDate = DateTime.parse(session.scheduledAt);
        return sessionDate.year == date.year &&
            sessionDate.month == date.month &&
            sessionDate.day == date.day;
      } catch (_) {
        return false;
      }
    }).toList();
  }
}
