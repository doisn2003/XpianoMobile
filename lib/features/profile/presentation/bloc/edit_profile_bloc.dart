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
    // Just a placeholder if we want to do something, 
    // but we'll handle the actual upload in _onEditProfileSubmit
  }

  Future<void> _onEditProfileSubmit(EditProfileSubmit event, Emitter<EditProfileState> emit) async {
    emit(EditProfileLoading());
    try {
      Map<String, dynamic> dataToUpdate = Map.from(event.profileData);

      // Nếu có chọn ảnh mới, thực hiện upload trước
      if (event.avatarFile != null) {
        emit(const EditProfileUploadingAvatar(0.1));
        final publicUrl = await mediaUploadService.uploadFile(
          file: event.avatarFile!,
          uploadType: 'avatar', // 🎯 Fix: Đổi user_avatar thành avatar
          onProgress: (p) => emit(EditProfileUploadingAvatar(p)),
        );
        dataToUpdate['avatar_url'] = publicUrl;
      }

      // Sau đó cập nhật toàn bộ profile (cohesive)
      final result = await authRepository.updateProfile(dataToUpdate);
      result.fold(
        (failure) => emit(EditProfileError(failure.message)),
        (user) => emit(EditProfileSuccess(user, 'Cập nhật thông tin thành công')),
      );
    } catch (e) {
      emit(EditProfileError('Lỗi cập nhật: $e'));
    }
  }
}
