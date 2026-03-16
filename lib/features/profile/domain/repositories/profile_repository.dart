import '../../../piano/domain/entities/piano.dart';
import '../entities/active_rental.dart';
import '../entities/order.dart';
import '../entities/wallet.dart';

abstract class ProfileRepository {
  Future<Wallet> getMyWallet();
  Future<bool> requestWithdrawal(double amount, Map<String, dynamic> bankInfo);
  Future<List<Piano>> getFavorites();
  Future<void> removeFavorite(int pianoId);
  Future<List<OrderItem>> getMyOrders();
  Future<List<ActiveRental>> getActiveRentals();
}
