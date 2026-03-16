import 'package:equatable/equatable.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();
  @override
  List<Object?> get props => [];
}

/// Load danh sách comments cho bài viết
class CommentLoadRequested extends CommentEvent {
  final String postId;
  const CommentLoadRequested(this.postId);
  @override
  List<Object?> get props => [postId];
}

/// Load thêm comments (pagination)
class CommentLoadMore extends CommentEvent {}

/// Gửi bình luận mới
class CommentSubmitted extends CommentEvent {
  final String content;
  final String? parentId;
  const CommentSubmitted(this.content, {this.parentId});
  @override
  List<Object?> get props => [content, parentId];
}

/// Xóa bình luận
class CommentDeleted extends CommentEvent {
  final String commentId;
  const CommentDeleted(this.commentId);
  @override
  List<Object?> get props => [commentId];
}
