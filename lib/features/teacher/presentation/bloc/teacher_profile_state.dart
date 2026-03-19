import 'package:equatable/equatable.dart';
import '../../data/models/teacher_profile_model.dart';

abstract class TeacherProfileState extends Equatable {
  const TeacherProfileState();

  @override
  List<Object?> get props => [];
}

class TeacherProfileInitial extends TeacherProfileState {}

class TeacherProfileLoading extends TeacherProfileState {}

/// Hồ sơ chưa tồn tại (chưa gửi lần nào).
class TeacherProfileNotFound extends TeacherProfileState {}

/// Hồ sơ đã tải thành công.
class TeacherProfileLoaded extends TeacherProfileState {
  final TeacherProfile profile;
  const TeacherProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Đang gửi hồ sơ.
class TeacherProfileSubmitting extends TeacherProfileState {}

/// Gửi hồ sơ thành công.
class TeacherProfileSubmitted extends TeacherProfileState {
  final TeacherProfile profile;
  const TeacherProfileSubmitted(this.profile);

  @override
  List<Object?> get props => [profile];
}

class TeacherProfileError extends TeacherProfileState {
  final String message;
  const TeacherProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
