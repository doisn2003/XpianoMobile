import 'dart:io';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/network/dio_client.dart';
import '../models/post_model.dart';
import 'package:path/path.dart' as p;

abstract class HomeRemoteDataSource {
  Future<List<PostModel>> getFeed();
  Future<PostModel> createPost({String? content, File? mediaFile});
  Future<void> likePost(String postId);
  Future<void> commentPost(String postId, String content);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final DioClient dioClient;
  final SupabaseClient supabaseClient;

  HomeRemoteDataSourceImpl({
    required this.dioClient,
    required this.supabaseClient,
  });

  @override
  Future<List<PostModel>> getFeed() async {
    try {
      // 1. Lấy Bài viết, lượt thích và lượt bình luận trực tiếp từ Supabase để tối đa tốc độ!
      final response = await supabaseClient
          .from('posts')
          .select('*, post_likes(user_id), post_comments(id)')
          .order('created_at', ascending: false)
          .limit(20);

      final List<dynamic> postsData = response;
      if (postsData.isEmpty) return [];

      // 2. Trích xuất danh sách user_id để lấy Profiles
      final userIds = postsData
          .map((p) => p['user_id'] as String?)
          .where((id) => id != null)
          .toSet()
          .toList();

      Map<String, dynamic> profileMap = {};
      
      if (userIds.isNotEmpty) {
        // Lấy Profiles một cách thủ công (Do Supabase không có Foreign Key trực tiếp từ posts sang public.profiles)
        final profilesResponse = await supabaseClient
            .from('profiles')
            .select('*')
            .inFilter('id', userIds);
            
        final List<dynamic> profilesData = profilesResponse;
        profileMap = {for (var p in profilesData) p['id']: p};
      }

      // 3. Kết hợp Dữ liệu vào PostModel
      return postsData.map((json) {
        final Map<String, dynamic> post = Map<String, dynamic>.from(json);
        post['likes_count'] = (post['post_likes'] as List?)?.length ?? 0;
        post['comments_count'] = (post['post_comments'] as List?)?.length ?? 0;
        
        // Gắn author profile vào để `PostModel.fromJson` tự nhận diện
        post['author'] = profileMap[post['user_id']];
        
        return PostModel.fromJson(post);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch feed: $e');
    }
  }

  @override
  Future<PostModel> createPost({String? content, File? mediaFile}) async {
    String? mediaTypeStr = 'none';
    List<String> mediaUrls = [];

    // NẾU CÓ FILE: Lấy Pre-signed URL và Upload
    if (mediaFile != null) {
      final fileName = p.basename(mediaFile.path);
      final extension = p.extension(mediaFile.path).toLowerCase();
      
      String contentType = 'application/octet-stream';
      String uploadType = 'post_image';
      
      if (['.jpg', '.jpeg', '.png', '.webp'].contains(extension)) {
        contentType = 'image/${extension.replaceAll('.', '').replaceFirst('jpg', 'jpeg')}';
        mediaTypeStr = 'image';
      } else if (['.mp4', '.mov'].contains(extension)) {
        contentType = 'video/${extension.replaceAll('.', '').replaceFirst('mov', 'quicktime')}';
        uploadType = 'post_video';
        mediaTypeStr = 'video';
      }

      int fileSize = await mediaFile.length();

      // 1. GET SIGNED URL
      final signResponse = await dioClient.post(
        '/upload/sign',
        data: {
          'uploadType': uploadType,
          'fileName': fileName,
          'fileSize': fileSize,
          'contentType': contentType,
        },
      );

      final signData = signResponse.data['data'];
      final signedUrl = signData['signedUrl'];
      final publicUrl = signData['publicUrl'];

      // 2. UPLOAD TO SUPABASE VIA DIO PUT
      // Tạo Dio instance mới để không bị dính AuthInterceptor vào domain của Supabase
      final binaryDio = Dio();
      await binaryDio.put(
        signedUrl,
        data: mediaFile.openRead(),
        options: Options(
          headers: {
            'Content-Type': contentType,
            'content-length': fileSize,
          },
        ),
      );

      mediaUrls.add(publicUrl);
    }

    // 3. GỌI API TẠO POST (Express)
    final createRes = await dioClient.post('/posts', data: {
      if (content != null && content.isNotEmpty) 'content': content,
      if (mediaUrls.isNotEmpty) 'media_urls': mediaUrls,
      'media_type': mediaTypeStr,
      'visibility': 'public',
      'post_type': 'general',
    });

    final newPostJson = createRes.data['data'];
    return PostModel.fromJson(newPostJson);
  }

  @override
  Future<void> likePost(String postId) async {
    await dioClient.post('/posts/$postId/like');
  }

  @override
  Future<void> commentPost(String postId, String content) async {
    await dioClient.post('/posts/$postId/comments', data: {
      'content': content,
    });
  }
}
