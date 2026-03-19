import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_remote_data_source.dart';
import '../datasources/post_supabase_data_source.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;
  final PostSupabaseDataSource supabaseDataSource;

  PostRepositoryImpl({
    required this.remoteDataSource,
    required this.supabaseDataSource,
  });

  @override
  Future<Either<Failure, List<Post>>> getFeed({
    String? cursor,
    int limit = 10,
    String? mediaType,
    String? currentUserId,
  }) async {
    try {
      // Read-heavy: đọc trực tiếp từ Supabase cho độ trễ siêu thấp
      final posts = await supabaseDataSource.getFeed(
        cursor: cursor,
        limit: limit,
        mediaType: mediaType,
        currentUserId: currentUserId,
      );
      return Right(posts);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      // Write operation: qua Express API
      final postData = <String, dynamic>{};
      if (content != null) postData['content'] = content;
      if (title != null) postData['title'] = title;
      if (mediaUrls != null && mediaUrls.isNotEmpty) postData['media_urls'] = mediaUrls;
      if (mediaType != null) postData['media_type'] = mediaType;
      if (postType != null) postData['post_type'] = postType;
      if (hashtags != null && hashtags.isNotEmpty) postData['hashtags'] = hashtags;
      if (location != null) postData['location'] = location;
      if (thumbnailUrl != null) postData['thumbnail_url'] = thumbnailUrl;
      if (duration != null) postData['duration'] = duration;
      if (relatedCourseId != null) postData['related_course_id'] = relatedCourseId;
      if (relatedPianoId != null) postData['related_piano_id'] = relatedPianoId;

      final post = await remoteDataSource.createPost(postData);
      return Right(post);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleLike(String postId, bool isCurrentlyLiked) async {
    try {
      await remoteDataSource.toggleLike(postId, isCurrentlyLiked);
      return Right(!isCurrentlyLiked);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> trackView(String postId) async {
    try {
      final result = await remoteDataSource.trackView(postId);
      return Right(result['views_count'] ?? 0);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> sharePost(String postId) async {
    try {
      final result = await remoteDataSource.sharePost(postId);
      return Right(result['shares_count'] ?? 0);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getTrendingHashtags({int limit = 20}) async {
    try {
      final hashtags = await remoteDataSource.getTrendingHashtags(limit: limit);
      return Right(hashtags);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> searchHashtags(String query, {int limit = 10}) async {
    try {
      final hashtags = await remoteDataSource.searchHashtags(query, limit: limit);
      return Right(hashtags);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, String>>> getSignedUploadUrl({
    required String uploadType,
    required String fileName,
    required int fileSize,
    required String contentType,
  }) async {
    try {
      final result = await remoteDataSource.getSignedUploadUrl({
        'uploadType': uploadType,
        'fileName': fileName,
        'fileSize': fileSize,
        'contentType': contentType,
      });
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ─── Comments ───

  @override
  Future<Either<Failure, List<Comment>>> getComments(String postId, {String? cursor, int limit = 20}) async {
    try {
      final comments = await remoteDataSource.getComments(postId, cursor: cursor, limit: limit);
      return Right(comments);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Comment>> addComment(String postId, String content, {String? parentId}) async {
    try {
      final comment = await remoteDataSource.addComment(postId, content, parentId: parentId);
      return Right(comment);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Comment>>> getReplies(String commentId, {String? cursor, int limit = 20}) async {
    try {
      final replies = await remoteDataSource.getReplies(commentId, cursor: cursor, limit: limit);
      return Right(replies);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment(String commentId) async {
    try {
      await remoteDataSource.deleteComment(commentId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ─── User Profile ───

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserPublicProfile(String userId) async {
    try {
      final profile = await remoteDataSource.getUserPublicProfile(userId);
      return Right(profile);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Post>>> getUserPosts(String userId, {String? cursor, int limit = 10}) async {
    try {
      final posts = await remoteDataSource.getUserPosts(userId, cursor: cursor, limit: limit);
      return Right(posts);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleFollowUser(String userId, bool isCurrentlyFollowing) async {
    try {
      await remoteDataSource.toggleFollowUser(userId, isCurrentlyFollowing);
      return Right(!isCurrentlyFollowing);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ─── Bookmark / Save ───

  @override
  Future<Either<Failure, bool>> toggleSave(String postId, bool isCurrentlySaved) async {
    try {
      await remoteDataSource.toggleSave(postId, isCurrentlySaved);
      return Right(!isCurrentlySaved);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Post>>> getSavedPosts({String? cursor, int limit = 10}) async {
    try {
      final posts = await remoteDataSource.getSavedPosts(cursor: cursor, limit: limit);
      return Right(posts);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
