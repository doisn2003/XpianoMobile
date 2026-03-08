import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/piano_repository.dart';
import 'piano_detail_event.dart';
import 'piano_detail_state.dart';

class PianoDetailBloc extends Bloc<PianoDetailEvent, PianoDetailState> {
  final PianoRepository pianoRepository;

  PianoDetailBloc({required this.pianoRepository}) : super(PianoDetailInitial()) {
    on<LoadPianoDetail>(_onLoadDetail);
    on<TogglePianoFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoadDetail(LoadPianoDetail event, Emitter<PianoDetailState> emit) async {
    emit(PianoDetailLoading());
    final result = await pianoRepository.getPianoById(event.pianoId);
    await result.fold(
      (failure) async => emit(PianoDetailError(failure.message)),
      (piano) async {
        // Thử check favorite (nếu chưa đăng nhập thì mặc định false)
        bool isFav = false;
        try {
          final favResult = await pianoRepository.checkFavorite(piano.id);
          favResult.fold((_) {}, (val) => isFav = val);
        } catch (_) {}
        emit(PianoDetailLoaded(piano: piano, isFavorited: isFav));
      },
    );
  }

  Future<void> _onToggleFavorite(TogglePianoFavorite event, Emitter<PianoDetailState> emit) async {
    final currentState = state;
    if (currentState is PianoDetailLoaded) {
      final result = await pianoRepository.toggleFavorite(event.pianoId, event.currentlyFavorited);
      result.fold(
        (failure) {}, // Silently fail — UI sẽ không đổi nếu lỗi
        (newFavState) => emit(currentState.copyWith(isFavorited: newFavState)),
      );
    }
  }
}
