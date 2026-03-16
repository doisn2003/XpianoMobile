import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/media_upload_service.dart';
import '../../domain/repositories/post_repository.dart';
import 'create_post_event.dart';
import 'create_post_state.dart';

class CreatePostBloc extends Bloc<CreatePostEvent, CreatePostState> {
  final PostRepository postRepository;
  final MediaUploadService uploadService;

  CreatePostBloc({
    required this.postRepository,
    required this.uploadService,
  }) : super(CreatePostInitial()) {
    on<SelectPostType>(_onSelectPostType);
    on<SelectMedia>(_onSelectMedia);
    on<RemoveMedia>(_onRemoveMedia);
    on<SubmitPost>(_onSubmitPost);
    on<ResetCreatePost>(_onReset);
    on<DismissUploadStatus>(_onDismiss);
  }

  void _onSelectPostType(SelectPostType event, Emitter<CreatePostState> emit) {
    emit(CreatePostEditing(mediaType: event.mediaType));
  }

  void _onSelectMedia(SelectMedia event, Emitter<CreatePostState> emit) {
    final current = state;
    if (current is CreatePostEditing) {
      emit(current.copyWith(selectedFiles: [...current.selectedFiles, ...event.files]));
    }
  }

  void _onRemoveMedia(RemoveMedia event, Emitter<CreatePostState> emit) {
    final current = state;
    if (current is CreatePostEditing) {
      final files = List<File>.from(current.selectedFiles);
      if (event.index >= 0 && event.index < files.length) {
        files.removeAt(event.index);
      }
      emit(current.copyWith(selectedFiles: files));
    }
  }

  Future<void> _onSubmitPost(SubmitPost event, Emitter<CreatePostState> emit) async {
    final current = state;
    if (current is! CreatePostEditing) return;

    try {
      List<String> mediaUrls = [];
      String? thumbnailUrl;
      int? duration;
      final mediaType = current.mediaType;

      // Upload media files nếu có
      if (current.selectedFiles.isNotEmpty) {
        if (mediaType == 'video') {
          // Upload video (có nén trước)
          emit(const CreatePostUploading(progress: 0.0, statusMessage: 'Đang chuẩn bị video...'));
          final videoUrl = await uploadService.uploadFile(
            file: current.selectedFiles.first,
            uploadType: 'post_video',
            onProgress: (p) {
              emit(CreatePostUploading(progress: p * 0.9, statusMessage: 'Đang tải video... ${(p * 100).toInt()}%'));
            },
            onStatusChange: (status) {
              emit(CreatePostUploading(progress: 0.0, statusMessage: status));
            },
          );
          mediaUrls = [videoUrl];

          // TODO: Extract thumbnail & duration from video
          // Sẽ thêm khi tích hợp video_compress package
        } else if (mediaType == 'image') {
          // Upload ảnh song song
          final totalFiles = current.selectedFiles.length;
          emit(CreatePostUploading(
            progress: 0.0,
            statusMessage: 'Đang chuẩn bị $totalFiles ảnh...',
          ));

          mediaUrls = await uploadService.uploadMultipleFiles(
            files: current.selectedFiles,
            uploadType: 'post_image',
            onProgress: (index, p) {
              final overallProgress = (index + p) / totalFiles;
              emit(CreatePostUploading(
                progress: overallProgress * 0.9,
                statusMessage: 'Đang tải ảnh ${index + 1}/$totalFiles... ${(p * 100).toInt()}%',
              ));
            },
            onStatusChange: (status) {
              emit(CreatePostUploading(progress: 0.0, statusMessage: status));
            },
          );
        }
      }

      // Tạo bài viết
      emit(const CreatePostUploading(progress: 0.95, statusMessage: 'Đang đăng bài...'));

      final result = await postRepository.createPost(
        content: event.content,
        title: event.title,
        mediaUrls: mediaUrls.isNotEmpty ? mediaUrls : null,
        mediaType: mediaType,
        postType: event.postType,
        hashtags: event.hashtags.isNotEmpty ? event.hashtags : null,
        location: event.location,
        thumbnailUrl: thumbnailUrl,
        duration: duration,
        relatedCourseId: event.relatedCourseId,
        relatedPianoId: event.relatedPianoId,
      );

      result.fold(
        (failure) => emit(CreatePostError(failure.message)),
        (post) => emit(CreatePostSuccess(post)),
      );
      // Không tự reset — để banner hiển thị trạng thái success/error
    } catch (e) {
      emit(CreatePostError(e.toString()));
    }
  }

  void _onReset(ResetCreatePost event, Emitter<CreatePostState> emit) {
    emit(CreatePostInitial());
  }

  void _onDismiss(DismissUploadStatus event, Emitter<CreatePostState> emit) {
    emit(CreatePostInitial());
  }
}
