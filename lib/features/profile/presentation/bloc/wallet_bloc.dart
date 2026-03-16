import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/profile_repository.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final ProfileRepository repository;

  WalletBloc({required this.repository}) : super(WalletInitial()) {
    on<LoadWallet>(_onLoadWallet);
    on<RequestWithdrawal>(_onRequestWithdrawal);
  }

  Future<void> _onLoadWallet(LoadWallet event, Emitter<WalletState> emit) async {
    emit(WalletLoading());
    try {
      final wallet = await repository.getMyWallet();
      emit(WalletLoaded(wallet));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> _onRequestWithdrawal(RequestWithdrawal event, Emitter<WalletState> emit) async {
    try {
      final success = await repository.requestWithdrawal(event.amount, event.bankInfo);
      if (success) {
        emit(const WalletWithdrawalSuccess('Gửi yêu cầu rút tiền thành công'));
        add(LoadWallet()); // Reload wallet after success
      }
    } catch (e) {
      emit(WalletError(e.toString()));
      add(LoadWallet()); // Go back to loaded state
    }
  }
}
