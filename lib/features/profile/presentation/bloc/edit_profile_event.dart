import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class EditProfileEvent extends Equatable {
  const EditProfileEvent();

  @override
  List<Object?> get props => [];
}

class EditProfileLoadInitial extends EditProfileEvent {}

class EditProfileAvatarChanged extends EditProfileEvent {
  final File imageFile;
  const EditProfileAvatarChanged(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}

class EditProfileSubmit extends EditProfileEvent {
  final Map<String, dynamic> profileData;
  final File? avatarFile;
  const EditProfileSubmit(this.profileData, {this.avatarFile});

  @override
  List<Object?> get props => [profileData, avatarFile];
}
