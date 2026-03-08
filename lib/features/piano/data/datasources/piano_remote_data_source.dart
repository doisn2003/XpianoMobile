import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/dio_client.dart';
import '../models/piano_model.dart';

abstract class PianoRemoteDataSource {
  Future<List<PianoModel>> getPianos({String? category});
  Future<PianoModel> getPianoById(int id);
  Future<Map<String, dynamic>> createOrder({
    required int pianoId,
    required String type,
    String? rentalStartDate,
    String? rentalEndDate,
    String paymentMethod = 'COD',
  });
  Future<bool> checkFavorite(int pianoId);
  Future<void> addFavorite(int pianoId);
  Future<void> removeFavorite(int pianoId);
}

class PianoRemoteDataSourceImpl implements PianoRemoteDataSource {
  final SupabaseClient supabaseClient;
  final DioClient dioClient;

  PianoRemoteDataSourceImpl({
    required this.supabaseClient,
    required this.dioClient,
  });

  // ═══════════════════════════════════════════════════════
  // Nhóm 1: Fetch trực tiếp từ Supabase (Read-Heavy)
  // ═══════════════════════════════════════════════════════

  @override
  Future<List<PianoModel>> getPianos({String? category}) async {
    var query = supabaseClient.from('pianos').select();

    if (category != null && category.isNotEmpty) {
      query = query.eq('category', category);
    }

    final response = await query.order('created_at', ascending: false);
    final List data = response as List;
    return data.map((json) => PianoModel.fromJson(json)).toList();
  }

  @override
  Future<PianoModel> getPianoById(int id) async {
    final response = await supabaseClient
        .from('pianos')
        .select()
        .eq('id', id)
        .single();
    return PianoModel.fromJson(response);
  }

  // ═══════════════════════════════════════════════════════
  // Nhóm 2: Gọi qua Express API (Write/Logic-Heavy)
  // ═══════════════════════════════════════════════════════

  @override
  Future<Map<String, dynamic>> createOrder({
    required int pianoId,
    required String type,
    String? rentalStartDate,
    String? rentalEndDate,
    String paymentMethod = 'COD',
  }) async {
    final body = <String, dynamic>{
      'piano_id': pianoId,
      'type': type,
      'payment_method': paymentMethod,
    };

    if (type == 'rent') {
      body['rental_start_date'] = rentalStartDate;
      body['rental_end_date'] = rentalEndDate;
    }

    final response = await dioClient.post('/orders', data: body);
    return response.data['data'] as Map<String, dynamic>;
  }

  @override
  Future<bool> checkFavorite(int pianoId) async {
    final response = await dioClient.get('/favorites/check/$pianoId');
    return response.data['isFavorited'] == true;
  }

  @override
  Future<void> addFavorite(int pianoId) async {
    await dioClient.post('/favorites/$pianoId');
  }

  @override
  Future<void> removeFavorite(int pianoId) async {
    await dioClient.delete('/favorites/$pianoId');
  }
}
