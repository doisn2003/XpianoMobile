import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../../../../core/network/dio_client.dart';

/// Data source cho các thao tác qua Express API (write + logic-heavy)
abstract class PostRemoteDataSource {
  Future<PostModel> createPost(Map<String, dynamic> postData);
  Future<Map<String, dynamic>> toggleLike(String postId, bool isCurrentlyLiked);
  Future<Map<String, dynamic>> trackView(String postId);
  Future<Map<String, dynamic>> sharePost(String postId);
  Future<Map<String, String>> getSignedUploadUrl(Map<String, dynamic> body);
  Future<List<Map<String, dynamic>>> getTrendingHashtags({int limit = 20});
  Future<List<Map<String, dynamic>>> searchHashtags(String query, {int limit = 10});

  // Comments
  Future<List<CommentModel>> getComments(String postId, {String? cursor, int limit = 20});
  Future<CommentModel> addComment(String postId, String content, {String? parentId});
  Future<List<CommentModel>> getReplies(String commentId, {String? cursor, int limit = 20});
  Future<void> deleteComment(String commentId);

  // User profile
  Future<Map<String, dynamic>> getUserPublicProfile(String userId);
  Future<List<PostModel>> getUserPosts(String userId, {String? cursor, int limit = 10});
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final DioClient dioClient;

  PostRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<PostModel> createPost(Map<String, dynamic> postData) async {
    final response = await dioClient.post('/posts', data: postData);
    final data = response.data['data'];
    return PostModel.fromJson(data);
  }

  @override
  Future<Map<String, dynamic>> toggleLike(String postId, bool isCurrentlyLiked) async {
    if (isCurrentlyLiked) {
      final response = await dioClient.delete('/posts/$postId/like');
      return Map<String, dynamic>.from(response.data['data'] ?? {});
    } else {
      final response = await dioClient.post('/posts/$postId/like');
      return Map<String, dynamic>.from(response.data['data'] ?? {});
    }
  }

  @override
  Future<Map<String, dynamic>> trackView(String postId) async {
    final response = await dioClient.post('/posts/$postId/view');
    return Map<String, dynamic>.from(response.data['data'] ?? {});
  }

  @override
  Future<Map<String, dynamic>> sharePost(String postId) async {
    final response = await dioClient.post('/posts/$postId/share');
    return Map<String, dynamic>.from(response.data['data'] ?? {});
  }

  @override
  Future<Map<String, String>> getSignedUploadUrl(Map<String, dynamic> body) async {
    final response = await dioClient.post('/upload/sign', data: body);
    final data = response.data['data'];
    return {
      'signedUrl': data['signedUrl']?.toString() ?? '',
      'publicUrl': data['publicUrl']?.toString() ?? '',
      'path': data['path']?.toString() ?? '',
      'token': data['token']?.toString() ?? '',
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getTrendingHashtags({int limit = 20}) async {
    final response = await dioClient.get('/posts/hashtags/trending', queryParameters: {'limit': limit});
    final data = response.data['data'] as List? ?? [];
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> searchHashtags(String query, {int limit = 10}) async {
    final response = await dioClient.get('/posts/hashtags/search', queryParameters: {'q': query, 'limit': limit});
    final data = response.data['data'] as List? ?? [];
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // ─── Comments ───

  @override
  Future<List<CommentModel>> getComments(String postId, {String? cursor, int limit = 20}) async {
    final params = <String, dynamic>{'limit': limit};
    if (cursor != null) params['cursor'] = cursor;
    final response = await dioClient.get('/posts/$postId/comments', queryParameters: params);
    final data = response.data['data'] as List? ?? [];
    return data.map((e) => CommentModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  @override
  Future<CommentModel> addComment(String postId, String content, {String? parentId}) async {
    final body = <String, dynamic>{'content': content};
    if (parentId != null) body['parent_id'] = parentId;
    final response = await dioClient.post('/posts/$postId/comments', data: body);
    return CommentModel.fromJson(Map<String, dynamic>.from(response.data['data']));
  }

  @override
  Future<List<CommentModel>> getReplies(String commentId, {String? cursor, int limit = 20}) async {
    final params = <String, dynamic>{'limit': limit};
    if (cursor != null) params['cursor'] = cursor;
    final response = await dioClient.get('/social/comments/$commentId/replies', queryParameters: params);
    final data = response.data['data'] as List? ?? [];
    return data.map((e) => CommentModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await dioClient.delete('/social/comments/$commentId');
  }

  // ─── User Profile ───

  @override
  Future<Map<String, dynamic>> getUserPublicProfile(String userId) async {
    final response = await dioClient.get('/social/users/$userId/public');
    return Map<String, dynamic>.from(response.data['data'] ?? {});
  }

  @override
  Future<List<PostModel>> getUserPosts(String userId, {String? cursor, int limit = 10}) async {
    final params = <String, dynamic>{'limit': limit};
    if (cursor != null) params['cursor'] = cursor;
    final response = await dioClient.get('/posts/user/$userId', queryParameters: params);
    final data = response.data['data'] as List? ?? [];
    return data.map((e) => PostModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }
}
