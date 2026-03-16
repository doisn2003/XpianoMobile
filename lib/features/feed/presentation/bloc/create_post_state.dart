import 'package:equatable/equatable.dart';
import 'dart:io';
import '../../domain/entities/post.dart';

/// States cho CreatePostBloc
abstract class CreatePostState extends Equatable {
  const CreatePostState();

  @override
  List<Object?> get props => [];
}

/// Trạng thái ban đầu
class CreatePostInitial extends CreatePostState {}

/// Đang soạn bài viết — giữ thông tin tạm
class CreatePostEditing extends CreatePostState {
  final String mediaType; // 'none', 'image', 'video'
  final List<File> selectedFiles;

  const CreatePostEditing({
    required this.mediaType,
    this.selectedFiles = const [],
  });

  CreatePostEditing copyWith({
    String? mediaType,
    List<File>? selectedFiles,
  }) {
    return CreatePostEditing(
      mediaType: mediaType ?? this.mediaType,
      selectedFiles: selectedFiles ?? this.selectedFiles,
    );
  }

  @override
  List<Object?> get props => [mediaType, selectedFiles];
}

/// Đang upload media
class CreatePostUploading extends CreatePostState {
  final double progress; // 0.0 → 1.0
  final String statusMessage;

  const CreatePostUploading({
    required this.progress,
    this.statusMessage = 'Đang tải lên...',
  });

  @override
  List<Object?> get props => [progress, statusMessage];
}

/// Tạo bài thành công
class CreatePostSuccess extends CreatePostState {
  final Post post;

  const CreatePostSuccess(this.post);

  @override
  List<Object?> get props => [post];
}

/// Lỗi
class CreatePostError extends CreatePostState {
  final String message;

  const CreatePostError(this.message);

  @override
  List<Object?> get props => [message];
}
