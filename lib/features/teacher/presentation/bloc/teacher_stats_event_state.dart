import 'package:equatable/equatable.dart';
import '../../data/models/teacher_stats_model.dart';

abstract class TeacherStatsEvent extends Equatable {
  const TeacherStatsEvent();
  @override
  List<Object?> get props => [];
}

class LoadTeacherStats extends TeacherStatsEvent {}

// --- States ---

abstract class TeacherStatsState extends Equatable {
  const TeacherStatsState();
  @override
  List<Object?> get props => [];
}

class TeacherStatsInitial extends TeacherStatsState {}

class TeacherStatsLoading extends TeacherStatsState {}

class TeacherStatsLoaded extends TeacherStatsState {
  final TeacherStats stats;
  const TeacherStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class TeacherStatsError extends TeacherStatsState {
  final String message;
  const TeacherStatsError(this.message);

  @override
  List<Object?> get props => [message];
}
