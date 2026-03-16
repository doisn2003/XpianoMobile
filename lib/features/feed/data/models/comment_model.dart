import '../../domain/entities/comment.dart';
import 'post_model.dart';

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.postId,
    required super.userId,
    required super.content,
    super.parentId,
    super.author,
    required super.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    PostAuthorModel? author;
    if (json['author'] is Map<String, dynamic>) {
      author = PostAuthorModel.fromJson(json['author']);
    }

    return CommentModel(
      id: json['id']?.toString() ?? '',
      postId: json['post_id'] ?? json['postId'] ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      content: json['content'] ?? '',
      parentId: json['parent_id'] ?? json['parentId'],
      author: author,
      createdAt: DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
