import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

class AppSupabaseClient {
  static final Logger _logger = Logger();

  static Future<void> initialize() async {
    try {
      final url = dotenv.env['SUPABASE_URL'];
      final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

      if (url == null || anonKey == null) {
        throw Exception('Thiếu thông tin URL hoặc AnonKey của Supabase trong biến môi trường.');
      }

      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );
      
      _logger.i('✅ Khởi động Supabase thành công!');
    } catch (e) {
      _logger.e('❌ Lỗi khởi động Supabase: $e');
      rethrow;
    }
  }

  /// Trả về instance của Supabase Client thay vì gọi thông qua Supabase.instance ở nhiều class phụ
  static SupabaseClient get client => Supabase.instance.client;
}
