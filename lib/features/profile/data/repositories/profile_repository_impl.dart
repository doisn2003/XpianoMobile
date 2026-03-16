import '../../../piano/domain/entities/piano.dart';
import '../../domain/entities/active_rental.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Wallet> getMyWallet() async {
    return await remoteDataSource.getMyWallet();
  }

  @override
  Future<bool> requestWithdrawal(double amount, Map<String, dynamic> bankInfo) async {
    return await remoteDataSource.requestWithdrawal(amount, bankInfo);
  }

  @override
  Future<List<Piano>> getFavorites() async {
    return await remoteDataSource.getFavorites();
  }

  @override
  Future<void> removeFavorite(int pianoId) async {
    await remoteDataSource.removeFavorite(pianoId);
  }

  @override
  Future<List<OrderItem>> getMyOrders() async {
    return await remoteDataSource.getMyOrders();
  }

  @override
  Future<List<ActiveRental>> getActiveRentals() async {
    return await remoteDataSource.getActiveRentals();
  }
}
