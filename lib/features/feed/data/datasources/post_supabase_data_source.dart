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
    // Build query: posts + profiles (author info)
    var query = supabaseClient
        .from('posts')
        .select('*, author:profiles!posts_user_id_fkey(id, full_name, avatar_url, role)')
        .eq('visibility', 'public');

    if (cursor != null) {
      query = query.lt('created_at', cursor);
    }

    if (mediaType != null && mediaType != 'all') {
      query = query.eq('media_type', mediaType);
    }

    // order + limit must be at the end of the chain
    final data = await query
        .order('created_at', ascending: false)
        .limit(limit);

    return (data as List).map((json) {
      final map = Map<String, dynamic>.from(json);
      // Supabase join trả author là object lồng, map đúng format
      if (map['author'] is List && (map['author'] as List).isNotEmpty) {
        map['author'] = map['author'][0];
      }
      return PostModel.fromJson(map);
    }).toList();
  }
}
