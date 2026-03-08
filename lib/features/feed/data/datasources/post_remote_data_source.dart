import '../models/post_model.dart';
import '../../../../core/network/dio_client.dart';

/// Data source cho các thao tác qua Express API (write operations)
abstract class PostRemoteDataSource {
  Future<PostModel> createPost(Map<String, dynamic> postData);
  Future<Map<String, dynamic>> toggleLike(String postId, bool isCurrentlyLiked);
  Future<Map<String, dynamic>> trackView(String postId);
  Future<Map<String, dynamic>> sharePost(String postId);
  Future<Map<String, String>> getSignedUploadUrl(Map<String, dynamic> body);
  Future<List<Map<String, dynamic>>> getTrendingHashtags({int limit = 20});
  Future<List<Map<String, dynamic>>> searchHashtags(String query, {int limit = 10});
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
}
