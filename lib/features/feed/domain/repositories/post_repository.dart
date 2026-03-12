import 'package:dartz/dartz.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/comment.dart';
import '../../../../core/error/failures.dart';

/// Repository interface cho Feed feature
abstract class PostRepository {
  /// Lấy feed (cursor-based pagination)
  Future<Either<Failure, List<Post>>> getFeed({
    String? cursor,
    int limit = 10,
    String? mediaType,
  });

  /// Tạo bài viết mới
  Future<Either<Failure, Post>> createPost({
    String? content,
    String? title,
    List<String>? mediaUrls,
    String? mediaType,
    String? postType,
    List<String>? hashtags,
    String? location,
    String? thumbnailUrl,
    int? duration,
    String? relatedCourseId,
    int? relatedPianoId,
  });

  /// Like/Unlike bài viết
  Future<Either<Failure, bool>> toggleLike(String postId, bool isCurrentlyLiked);

  /// Ghi nhận lượt xem
  Future<Either<Failure, int>> trackView(String postId);

  /// Chia sẻ bài viết
  Future<Either<Failure, int>> sharePost(String postId);

  /// Lấy trending hashtags
  Future<Either<Failure, List<Map<String, dynamic>>>> getTrendingHashtags({int limit = 20});

  /// Tìm kiếm hashtags
  Future<Either<Failure, List<Map<String, dynamic>>>> searchHashtags(String query, {int limit = 10});

  /// Xin PreSigned URL để upload media
  Future<Either<Failure, Map<String, String>>> getSignedUploadUrl({
    required String uploadType,
    required String fileName,
    required int fileSize,
    required String contentType,
  });

  // ─── Comments ───
  Future<Either<Failure, List<Comment>>> getComments(String postId, {String? cursor, int limit = 20});
  Future<Either<Failure, Comment>> addComment(String postId, String content, {String? parentId});
  Future<Either<Failure, List<Comment>>> getReplies(String commentId, {String? cursor, int limit = 20});
  Future<Either<Failure, void>> deleteComment(String commentId);

  // ─── User Profile ───
  Future<Either<Failure, Map<String, dynamic>>> getUserPublicProfile(String userId);
  Future<Either<Failure, List<Post>>> getUserPosts(String userId, {String? cursor, int limit = 10});
}
