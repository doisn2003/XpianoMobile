import 'package:equatable/equatable.dart';

abstract class TeacherProfileEvent extends Equatable {
  const TeacherProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Load hồ sơ giáo viên hiện tại (gọi 1 lần khi mở Teacher area).
class LoadTeacherProfile extends TeacherProfileEvent {}

/// Gửi / cập nhật hồ sơ giáo viên.
class SubmitTeacherProfile extends TeacherProfileEvent {
  final Map<String, dynamic> body;
  const SubmitTeacherProfile(this.body);

  @override
  List<Object?> get props => [body];
}
