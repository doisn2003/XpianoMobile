import 'package:equatable/equatable.dart';
import '../../domain/entities/wallet.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final Wallet wallet;
  const WalletLoaded(this.wallet);

  @override
  List<Object?> get props => [wallet];
}

class WalletError extends WalletState {
  final String message;
  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}

class WalletWithdrawalSuccess extends WalletState {
  final String message;
  const WalletWithdrawalSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
