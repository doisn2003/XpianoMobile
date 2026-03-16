import 'transaction.dart';

class Wallet {
  final int id;
  final double availableBalance;
  final double lockedBalance;
  final double totalBalance;
  final List<Transaction> transactions;
  final List<WithdrawalRequest> withdrawalRequests;
  final String? createdAt;
  final String? updatedAt;

  const Wallet({
    required this.id,
    required this.availableBalance,
    required this.lockedBalance,
    required this.totalBalance,
    required this.transactions,
    required this.withdrawalRequests,
    this.createdAt,
    this.updatedAt,
  });
}

class WithdrawalRequest {
  final int id;
  final double amount;
  final Map<String, dynamic> bankInfo;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  const WithdrawalRequest({
    required this.id,
    required this.amount,
    required this.bankInfo,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });
}
