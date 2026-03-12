import 'package:equatable/equatable.dart';
import 'post.dart';

/// Comment entity — đại diện cho 1 bình luận trên bài viết
class Comment extends Equatable {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final String? parentId;
  final PostAuthor? author;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    this.parentId,
    this.author,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, postId, userId, content, parentId, author, createdAt];
}
