import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../../core/services/media_upload_service.dart';
import 'edit_profile_event.dart';
import 'edit_profile_state.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  final AuthRepository authRepository;
  final MediaUploadService mediaUploadService;

  EditProfileBloc({
    required this.authRepository,
    required this.mediaUploadService,
  }) : super(EditProfileInitial()) {
    on<EditProfileAvatarChanged>(_onAvatarChanged);
    on<EditProfileSubmit>(_onEditProfileSubmit);
  }

  Future<void> _onAvatarChanged(EditProfileAvatarChanged event, Emitter<EditProfileState> emit) async {
    emit(const EditProfileUploadingAvatar(0.0));
    try {
      final publicUrl = await mediaUploadService.uploadFile(
        file: event.imageFile,
        uploadType: 'user_avatar', 
        onProgress: (progress) => emit(EditProfileUploadingAvatar(progress)),
        onStatusChange: (status) => {}, // Can log if needed
      );

      // Successfully uploaded, now we can update the profile with this URL
      final result = await authRepository.updateProfile({'avatar_url': publicUrl});
      result.fold(
        (failure) => emit(EditProfileError(failure.message)),
        (user) => emit(EditProfileSuccess(user, 'Cập nhật ảnh đại diện thành công')),
      );
    } catch (e) {
      emit(EditProfileError('Lỗi upload ảnh: $e'));
    }
  }

  Future<void> _onEditProfileSubmit(EditProfileSubmit event, Emitter<EditProfileState> emit) async {
    emit(EditProfileLoading());
    final result = await authRepository.updateProfile(event.profileData);
    result.fold(
      (failure) => emit(EditProfileError(failure.message)),
      (user) => emit(EditProfileSuccess(user, 'Cập nhật thông tin thành công')),
    );
  }
}
