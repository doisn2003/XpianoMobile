import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/teacher_repository.dart';
import 'teacher_stats_event_state.dart';

class TeacherStatsBloc extends Bloc<TeacherStatsEvent, TeacherStatsState> {
  final TeacherRepository repository;

  TeacherStatsBloc({required this.repository})
      : super(TeacherStatsInitial()) {
    on<LoadTeacherStats>(_onLoad);
  }

  Future<void> _onLoad(
    LoadTeacherStats event,
    Emitter<TeacherStatsState> emit,
  ) async {
    emit(TeacherStatsLoading());
    try {
      final stats = await repository.getStats();
      emit(TeacherStatsLoaded(stats));
    } catch (e) {
      emit(TeacherStatsError(e.toString()));
    }
  }
}
