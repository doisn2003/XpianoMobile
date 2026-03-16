import '../../domain/entities/transaction.dart';
import '../../domain/entities/wallet.dart';
import 'transaction_model.dart';

class WalletModel extends Wallet {
  const WalletModel({
    required super.id,
    required super.availableBalance,
    required super.lockedBalance,
    required super.totalBalance,
    required super.transactions,
    required super.withdrawalRequests,
    super.createdAt,
    super.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as int,
      availableBalance: (json['available_balance'] as num).toDouble(),
      lockedBalance: (json['locked_balance'] as num).toDouble(),
      totalBalance: (json['total_balance'] as num).toDouble(),
      transactions: [], // handled separately if needed, or parse here
      withdrawalRequests: [], // handled separately
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

class WithdrawalRequestModel extends WithdrawalRequest {
  const WithdrawalRequestModel({
    required super.id,
    required super.amount,
    required super.bankInfo,
    required super.status,
    super.createdAt,
    super.updatedAt,
  });

  factory WithdrawalRequestModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequestModel(
      id: json['id'] as int,
      amount: (json['amount'] as num).toDouble(),
      bankInfo: json['bank_info'] as Map<String, dynamic>? ?? {},
      status: json['status'] as String,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}
