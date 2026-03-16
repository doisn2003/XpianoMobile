import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user.dart';

abstract class EditProfileState extends Equatable {
  const EditProfileState();

  @override
  List<Object?> get props => [];
}

class EditProfileInitial extends EditProfileState {}

class EditProfileLoading extends EditProfileState {}

class EditProfileUploadingAvatar extends EditProfileState {
  final double progress;
  const EditProfileUploadingAvatar(this.progress);

  @override
  List<Object?> get props => [progress];
}

class EditProfileSuccess extends EditProfileState {
  final User user;
  final String message;
  const EditProfileSuccess(this.user, this.message);

  @override
  List<Object?> get props => [user, message];
}

class EditProfileError extends EditProfileState {
  final String message;
  const EditProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
