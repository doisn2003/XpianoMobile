import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/piano.dart';

abstract class PianoRepository {
  /// Lấy danh sách piano (từ Supabase — Read-Heavy)
  Future<Either<Failure, List<Piano>>> getPianos({String? category});

  /// Lấy chi tiết 1 cây piano (từ Supabase — Read-Heavy)
  Future<Either<Failure, Piano>> getPianoById(int id);

  /// Tạo đơn hàng mua/mượn (qua Express — Write-Heavy)
  Future<Either<Failure, Map<String, dynamic>>> createOrder({
    required int pianoId,
    required String type, // 'buy' hoặc 'rent'
    String? rentalStartDate,
    String? rentalEndDate,
    String paymentMethod, // 'COD' hoặc 'QR'
  });

  /// Toggle yêu thích (qua Express — Write-Heavy)
  Future<Either<Failure, bool>> toggleFavorite(int pianoId, bool currentlyFavorited);

  /// Kiểm tra đã yêu thích chưa (qua Express — Read Auth)
  Future<Either<Failure, bool>> checkFavorite(int pianoId);
}
