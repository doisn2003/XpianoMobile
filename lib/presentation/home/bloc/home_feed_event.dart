import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class HomeFeedEvent extends Equatable {
  const HomeFeedEvent();

  @override
  List<Object?> get props => [];
}

class LoadFeedEvent extends HomeFeedEvent {}

class LikePostEvent extends HomeFeedEvent {
  final String postId;
  const LikePostEvent(this.postId);

  @override
  List<Object> get props => [postId];
}

class CreatePostEvent extends HomeFeedEvent {
  final String? content;
  final File? mediaFile;

  const CreatePostEvent({this.content, this.mediaFile});

  @override
  List<Object?> get props => [content, mediaFile?.path];
}
