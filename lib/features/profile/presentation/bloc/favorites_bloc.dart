import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/profile_repository.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final ProfileRepository repository;

  FavoritesBloc({required this.repository}) : super(FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<RemoveFavorite>(_onRemoveFavorite);
  }

  Future<void> _onLoadFavorites(LoadFavorites event, Emitter<FavoritesState> emit) async {
    emit(FavoritesLoading());
    try {
      final favorites = await repository.getFavorites();
      emit(FavoritesLoaded(favorites));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> _onRemoveFavorite(RemoveFavorite event, Emitter<FavoritesState> emit) async {
    if (state is FavoritesLoaded) {
      final currentState = state as FavoritesLoaded;
      try {
        await repository.removeFavorite(event.pianoId);
        // Optimistic update
        final updatedFavorites = currentState.favorites.where((p) => p.id != event.pianoId).toList();
        emit(FavoritesLoaded(updatedFavorites));
      } catch (e) {
        // Bỏ qua lỗi, không làm gián đoạn list nếu chỉ bị lỗi lúc Remove
      }
    }
  }
}
