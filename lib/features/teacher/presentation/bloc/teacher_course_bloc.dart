import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/teacher_repository.dart';
import '../../../explore/data/models/course_model.dart';
import 'teacher_course_event.dart';
import 'teacher_course_state.dart';

class TeacherCourseBloc
    extends Bloc<TeacherCourseEvent, TeacherCourseState> {
  final TeacherRepository repository;

  TeacherCourseBloc({required this.repository})
      : super(TeacherCourseInitial()) {
    on<LoadTeacherCourses>(_onLoad);
    on<CreateTeacherCourse>(_onCreate);
    on<UpdateTeacherCourse>(_onUpdate);
    on<PublishTeacherCourse>(_onPublish);
    on<DeleteTeacherCourse>(_onDelete);
  }

  List<CourseModel> _currentCourses = [];

  Future<void> _onLoad(
    LoadTeacherCourses event,
    Emitter<TeacherCourseState> emit,
  ) async {
    emit(TeacherCourseLoading());
    try {
      _currentCourses = await repository.getMyTeachingCourses();
      emit(TeacherCourseLoaded(_currentCourses));
    } catch (e) {
      emit(TeacherCourseError(e.toString(), courses: _currentCourses));
    }
  }

  Future<void> _onCreate(
    CreateTeacherCourse event,
    Emitter<TeacherCourseState> emit,
  ) async {
    emit(TeacherCourseActionLoading(_currentCourses));
    try {
      final course = await repository.createCourse(event.body);
      _currentCourses = [course, ..._currentCourses];
      emit(TeacherCourseActionSuccess(
          'Tạo khóa học thành công!', _currentCourses));
    } catch (e) {
      emit(TeacherCourseError(e.toString(), courses: _currentCourses));
    }
  }

  Future<void> _onUpdate(
    UpdateTeacherCourse event,
    Emitter<TeacherCourseState> emit,
  ) async {
    emit(TeacherCourseActionLoading(_currentCourses));
    try {
      final updated = await repository.updateCourse(event.courseId, event.body);
      _currentCourses = _currentCourses
          .map((c) => c.id == updated.id ? updated : c)
          .toList();
      emit(TeacherCourseActionSuccess(
          'Cập nhật thành công!', _currentCourses));
    } catch (e) {
      emit(TeacherCourseError(e.toString(), courses: _currentCourses));
    }
  }

  Future<void> _onPublish(
    PublishTeacherCourse event,
    Emitter<TeacherCourseState> emit,
  ) async {
    emit(TeacherCourseActionLoading(_currentCourses));
    try {
      await repository.publishCourse(event.courseId);
      // Reload để lấy status mới
      _currentCourses = await repository.getMyTeachingCourses();
      emit(TeacherCourseActionSuccess(
          'Xuất bản khóa học thành công!', _currentCourses));
    } catch (e) {
      emit(TeacherCourseError(e.toString(), courses: _currentCourses));
    }
  }

  Future<void> _onDelete(
    DeleteTeacherCourse event,
    Emitter<TeacherCourseState> emit,
  ) async {
    emit(TeacherCourseActionLoading(_currentCourses));
    try {
      await repository.deleteCourse(event.courseId);
      _currentCourses = _currentCourses
          .where((c) => c.id != event.courseId)
          .toList();
      emit(TeacherCourseActionSuccess(
          'Đã xóa khóa học thành công!', _currentCourses));
    } catch (e) {
      emit(TeacherCourseError(e.toString(), courses: _currentCourses));
    }
  }
}
