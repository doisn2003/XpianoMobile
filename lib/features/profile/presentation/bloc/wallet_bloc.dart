import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/profile_repository.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final ProfileRepository repository;

  WalletBloc({required this.repository}) : super(WalletInitial()) {
    on<LoadWallet>(_onLoadWallet);
    on<ToggleBalanceVisibility>(_onToggleBalanceVisibility);
    on<RequestWithdrawal>(_onRequestWithdrawal);
  }

  void _onToggleBalanceVisibility(ToggleBalanceVisibility event, Emitter<WalletState> emit) {
    final bool newVisibility = !state.isBalanceVisible;
    if (state is WalletLoaded) {
      emit((state as WalletLoaded).copyWith(isBalanceVisible: newVisibility));
    } else if (state is WalletInitial) {
      emit(WalletInitial(isBalanceVisible: newVisibility));
    } else if (state is WalletLoading) {
      emit(WalletLoading(isBalanceVisible: newVisibility));
    } else if (state is WalletError) {
      emit(WalletError((state as WalletError).message, isBalanceVisible: newVisibility));
    } else if (state is WalletWithdrawalSuccess) {
      emit(WalletWithdrawalSuccess((state as WalletWithdrawalSuccess).message, isBalanceVisible: newVisibility));
    }
  }

  Future<void> _onLoadWallet(LoadWallet event, Emitter<WalletState> emit) async {
    final bool currentVisibility = state.isBalanceVisible;
    emit(WalletLoading(isBalanceVisible: currentVisibility));
    try {
      final wallet = await repository.getMyWallet();
      emit(WalletLoaded(wallet, isBalanceVisible: currentVisibility));
    } catch (e) {
      emit(WalletError(e.toString(), isBalanceVisible: currentVisibility));
    }
  }

  Future<void> _onRequestWithdrawal(RequestWithdrawal event, Emitter<WalletState> emit) async {
    final bool currentVisibility = state.isBalanceVisible;
    try {
      final success = await repository.requestWithdrawal(event.amount, event.bankInfo);
      if (success) {
        emit(WalletWithdrawalSuccess('Gửi yêu cầu rút tiền thành công', isBalanceVisible: currentVisibility));
        add(LoadWallet()); // Reload wallet after success
      }
    } catch (e) {
      emit(WalletError(e.toString(), isBalanceVisible: currentVisibility));
      add(LoadWallet()); // Go back to loaded state
    }
  }
}
