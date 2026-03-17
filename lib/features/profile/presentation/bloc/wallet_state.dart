import 'package:equatable/equatable.dart';
import '../../domain/entities/wallet.dart';

abstract class WalletState extends Equatable {
  final bool isBalanceVisible;
  const WalletState({this.isBalanceVisible = false});

  @override
  List<Object?> get props => [isBalanceVisible];
}

class WalletInitial extends WalletState {
  const WalletInitial({super.isBalanceVisible});
}

class WalletLoading extends WalletState {
  const WalletLoading({super.isBalanceVisible});
}

class WalletLoaded extends WalletState {
  final Wallet wallet;
  
  const WalletLoaded(this.wallet, {super.isBalanceVisible});

  @override
  List<Object?> get props => [wallet, isBalanceVisible];

  WalletLoaded copyWith({
    Wallet? wallet,
    bool? isBalanceVisible,
  }) {
    return WalletLoaded(
      wallet ?? this.wallet,
      isBalanceVisible: isBalanceVisible ?? this.isBalanceVisible,
    );
  }
}

class WalletError extends WalletState {
  final String message;
  const WalletError(this.message, {super.isBalanceVisible});

  @override
  List<Object?> get props => [message, isBalanceVisible];
}

class WalletWithdrawalSuccess extends WalletState {
  final String message;
  const WalletWithdrawalSuccess(this.message, {super.isBalanceVisible});

  @override
  List<Object?> get props => [message, isBalanceVisible];
}
