import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/piano_repository.dart';
import 'piano_order_event.dart';
import 'piano_order_state.dart';

class PianoOrderBloc extends Bloc<PianoOrderEvent, PianoOrderState> {
  final PianoRepository pianoRepository;

  PianoOrderBloc({required this.pianoRepository}) : super(PianoOrderInitial()) {
    on<CreatePianoOrder>(_onCreateOrder);
  }

  Future<void> _onCreateOrder(CreatePianoOrder event, Emitter<PianoOrderState> emit) async {
    emit(PianoOrderLoading());
    final result = await pianoRepository.createOrder(
      pianoId: event.pianoId,
      type: event.type,
      rentalStartDate: event.rentalStartDate,
      rentalEndDate: event.rentalEndDate,
      paymentMethod: event.paymentMethod,
    );
    result.fold(
      (failure) => emit(PianoOrderError(failure.message)),
      (data) => emit(PianoOrderSuccess(data)),
    );
  }
}
