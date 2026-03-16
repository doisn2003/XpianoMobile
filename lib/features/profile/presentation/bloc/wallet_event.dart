import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class LoadWallet extends WalletEvent {}

class RequestWithdrawal extends WalletEvent {
  final double amount;
  final Map<String, dynamic> bankInfo;

  const RequestWithdrawal({required this.amount, required this.bankInfo});

  @override
  List<Object?> get props => [amount, bankInfo];
}
