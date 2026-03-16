import '../../../../core/network/dio_client.dart';
import '../../../piano/data/models/piano_model.dart';
import '../models/active_rental_model.dart';
import '../models/order_model.dart';
import '../models/wallet_model.dart';

abstract class ProfileRemoteDataSource {
  Future<WalletModel> getMyWallet();
  Future<bool> requestWithdrawal(double amount, Map<String, dynamic> bankInfo);
  Future<List<PianoModel>> getFavorites();
  Future<void> removeFavorite(int pianoId);
  Future<List<OrderItemModel>> getMyOrders();
  Future<List<ActiveRentalModel>> getActiveRentals();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient dioClient;

  ProfileRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<WalletModel> getMyWallet() async {
    final response = await dioClient.get('/wallet/my-wallet');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'];
      
      final walletMap = data['wallet'] as Map<String, dynamic>;
      
      // Parse lists if existing
      final txsStr = data['transactions'] as List?;
      final withdrawStr = data['withdrawal_requests'] as List?;
      
      // We merge into one object for WalletModel
      walletMap['transactions'] = txsStr;
      walletMap['withdrawal_requests'] = withdrawStr;

      return WalletModel.fromJson(walletMap);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to load wallet');
    }
  }

  @override
  Future<bool> requestWithdrawal(double amount, Map<String, dynamic> bankInfo) async {
    final response = await dioClient.post('/wallet/withdraw', data: {
      'amount': amount,
      'bank_info': bankInfo,
    });
    if (response.statusCode == 200 && response.data['success'] == true) {
      return true;
    } else {
      throw Exception(response.data['message'] ?? 'Failed to request withdrawal');
    }
  }

  @override
  Future<List<PianoModel>> getFavorites() async {
    final response = await dioClient.get('/favorites');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List data = response.data['data'];
      return data.where((e) => e != null && e['piano'] != null).map((e) => PianoModel.fromJson(e['piano'] as Map<String, dynamic>)).toList();
    } else {
      throw Exception(response.data['message'] ?? 'Failed to load favorites');
    }
  }

  @override
  Future<void> removeFavorite(int pianoId) async {
    final response = await dioClient.delete('/favorites/$pianoId');
    if (response.statusCode != 200 || response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to remove favorite');
    }
  }

  @override
  Future<List<OrderItemModel>> getMyOrders() async {
    final response = await dioClient.get('/orders/my-orders');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List data = response.data['data'];
      return data.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception(response.data['message'] ?? 'Failed to load orders');
    }
  }

  @override
  Future<List<ActiveRentalModel>> getActiveRentals() async {
    final response = await dioClient.get('/orders/active-rentals');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List data = response.data['data'];
      return data.map((e) => ActiveRentalModel.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception(response.data['message'] ?? 'Failed to load active rentals');
    }
  }
}
