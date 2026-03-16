import 'package:equatable/equatable.dart';
import 'dart:io';

/// Events cho CreatePostBloc
abstract class CreatePostEvent extends Equatable {
  const CreatePostEvent();

  @override
  List<Object?> get props => [];
}

/// Chọn loại bài viết
class SelectPostType extends CreatePostEvent {
  final String mediaType; // 'none', 'image', 'video'
  const SelectPostType(this.mediaType);

  @override
  List<Object?> get props => [mediaType];
}

/// Chọn file media (ảnh hoặc video)
class SelectMedia extends CreatePostEvent {
  final List<File> files;
  const SelectMedia(this.files);

  @override
  List<Object?> get props => [files];
}

/// Xóa 1 file media khỏi danh sách
class RemoveMedia extends CreatePostEvent {
  final int index;
  const RemoveMedia(this.index);

  @override
  List<Object?> get props => [index];
}

/// Submit bài viết — upload media rồi tạo post
class SubmitPost extends CreatePostEvent {
  final String? content;
  final String? title;
  final List<String> hashtags;
  final String? location;
  final String postType;
  final String? relatedCourseId;
  final int? relatedPianoId;

  const SubmitPost({
    this.content,
    this.title,
    this.hashtags = const [],
    this.location,
    this.postType = 'general',
    this.relatedCourseId,
    this.relatedPianoId,
  });

  @override
  List<Object?> get props => [content, title, hashtags, location, postType, relatedCourseId, relatedPianoId];
}

/// Reset form
class ResetCreatePost extends CreatePostEvent {}

/// Dismiss upload status (khi user ấn "Xem ngay" hoặc dismiss banner)
class DismissUploadStatus extends CreatePostEvent {}
