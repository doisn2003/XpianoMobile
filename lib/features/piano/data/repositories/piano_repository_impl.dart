import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/piano.dart';
import '../../domain/repositories/piano_repository.dart';
import '../datasources/piano_remote_data_source.dart';

class PianoRepositoryImpl implements PianoRepository {
  final PianoRemoteDataSource remoteDataSource;

  PianoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Piano>>> getPianos({String? category}) async {
    try {
      final pianos = await remoteDataSource.getPianos(category: category);
      return Right(pianos);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Piano>> getPianoById(int id) async {
    try {
      final piano = await remoteDataSource.getPianoById(id);
      return Right(piano);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createOrder({
    required int pianoId,
    required String type,
    String? rentalStartDate,
    String? rentalEndDate,
    String paymentMethod = 'COD',
  }) async {
    try {
      final result = await remoteDataSource.createOrder(
        pianoId: pianoId,
        type: type,
        rentalStartDate: rentalStartDate,
        rentalEndDate: rentalEndDate,
        paymentMethod: paymentMethod,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleFavorite(int pianoId, bool currentlyFavorited) async {
    try {
      if (currentlyFavorited) {
        await remoteDataSource.removeFavorite(pianoId);
      } else {
        await remoteDataSource.addFavorite(pianoId);
      }
      return Right(!currentlyFavorited);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkFavorite(int pianoId) async {
    try {
      final isFav = await remoteDataSource.checkFavorite(pianoId);
      return Right(isFav);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
