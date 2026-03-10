import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_model.dart';

/// Data source cho thao tác đọc trực tiếp từ Supabase (read-heavy, low latency)
abstract class PostSupabaseDataSource {
  Future<List<PostModel>> getFeed({
    String? cursor,
    int limit = 10,
    String? mediaType,
  });
}

class PostSupabaseDataSourceImpl implements PostSupabaseDataSource {
  final SupabaseClient supabaseClient;

  PostSupabaseDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<PostModel>> getFeed({
    String? cursor,
    int limit = 10,
    String? mediaType,
  }) async {
    // Bước 1: Lấy posts
    var query = supabaseClient
        .from('posts')
        .select()
        .eq('visibility', 'public');

    if (cursor != null) {
      query = query.lt('created_at', cursor);
    }

    if (mediaType != null && mediaType != 'all') {
      query = query.eq('media_type', mediaType);
    }

    final data = await query
        .order('created_at', ascending: false)
        .limit(limit);

    final posts = (data as List).map((e) => Map<String, dynamic>.from(e)).toList();

    if (posts.isEmpty) return [];

    // Bước 2: Lấy author info từ profiles (batch query)
    final userIds = posts.map((p) => p['user_id']).whereType<String>().toSet().toList();

    Map<String, Map<String, dynamic>> authorMap = {};
    if (userIds.isNotEmpty) {
      try {
        final profiles = await supabaseClient
            .from('profiles')
            .select('id, full_name, avatar_url, role')
            .inFilter('id', userIds);
        for (final profile in (profiles as List)) {
          final p = Map<String, dynamic>.from(profile);
          authorMap[p['id']] = p;
        }
      } catch (_) {
        // Nếu không lấy được profiles, hiển thị posts mà không có author info
      }
    }

    // Bước 3: Gắn author vào mỗi post
    return posts.map((json) {
      final userId = json['user_id'];
      if (userId != null && authorMap.containsKey(userId)) {
        json['author'] = authorMap[userId];
      }
      return PostModel.fromJson(json);
    }).toList();
  }
}
