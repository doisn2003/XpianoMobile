import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/teacher_repository.dart';
import 'teacher_profile_event.dart';
import 'teacher_profile_state.dart';

class TeacherProfileBloc
    extends Bloc<TeacherProfileEvent, TeacherProfileState> {
  final TeacherRepository repository;

  TeacherProfileBloc({required this.repository})
      : super(TeacherProfileInitial()) {
    on<LoadTeacherProfile>(_onLoad);
    on<SubmitTeacherProfile>(_onSubmit);
  }

  Future<void> _onLoad(
    LoadTeacherProfile event,
    Emitter<TeacherProfileState> emit,
  ) async {
    emit(TeacherProfileLoading());
    try {
      final profile = await repository.getMyProfile();
      if (profile == null) {
        emit(TeacherProfileNotFound());
      } else {
        emit(TeacherProfileLoaded(profile));
      }
    } catch (e) {
      emit(TeacherProfileError(e.toString()));
    }
  }

  Future<void> _onSubmit(
    SubmitTeacherProfile event,
    Emitter<TeacherProfileState> emit,
  ) async {
    emit(TeacherProfileSubmitting());
    try {
      final profile = await repository.submitProfile(event.body);
      emit(TeacherProfileSubmitted(profile));
    } catch (e) {
      emit(TeacherProfileError(e.toString()));
    }
  }
}
