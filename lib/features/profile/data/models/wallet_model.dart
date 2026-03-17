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
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      availableBalance: (json['available_balance'] as num?)?.toDouble() ?? 0.0,
      lockedBalance: (json['locked_balance'] as num?)?.toDouble() ?? 0.0,
      totalBalance: (json['total_balance'] as num?)?.toDouble() ?? 0.0,
      transactions: (json['transactions'] as List?)?.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      withdrawalRequests: (json['withdrawal_requests'] as List?)?.map((e) => WithdrawalRequestModel.fromJson(e as Map<String, dynamic>)).toList() ?? [],
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
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      bankInfo: json['bank_info'] as Map<String, dynamic>? ?? {},
      status: json['status'] as String,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}
