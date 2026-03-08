import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/piano.dart';
import '../../domain/repositories/piano_repository.dart';
import 'piano_list_event.dart';
import 'piano_list_state.dart';

class PianoListBloc extends Bloc<PianoListEvent, PianoListState> {
  final PianoRepository pianoRepository;

  PianoListBloc({required this.pianoRepository}) : super(PianoListInitial()) {
    on<LoadPianos>(_onLoadPianos);
    on<FilterByCategory>(_onFilterByCategory);
    on<SearchPianos>(_onSearchPianos);
  }

  Future<void> _onLoadPianos(LoadPianos event, Emitter<PianoListState> emit) async {
    emit(PianoListLoading());
    final result = await pianoRepository.getPianos();
    result.fold(
      (failure) => emit(PianoListError(failure.message)),
      (pianos) {
        final categories = pianos.map((p) => p.category).toSet().toList()..sort();
        emit(PianoListLoaded(
          pianos: pianos,
          allPianos: pianos,
          categories: categories,
        ));
      },
    );
  }

  Future<void> _onFilterByCategory(FilterByCategory event, Emitter<PianoListState> emit) async {
    final currentState = state;
    if (currentState is PianoListLoaded) {
      final filtered = event.category == null || event.category!.isEmpty
          ? currentState.allPianos
          : currentState.allPianos.where((p) => p.category == event.category).toList();

      // Áp dụng search query hiện tại nếu có
      final finalList = _applySearch(filtered, currentState.searchQuery);

      emit(PianoListLoaded(
        pianos: finalList,
        allPianos: currentState.allPianos,
        categories: currentState.categories,
        activeCategory: event.category,
        searchQuery: currentState.searchQuery,
      ));
    }
  }

  Future<void> _onSearchPianos(SearchPianos event, Emitter<PianoListState> emit) async {
    final currentState = state;
    if (currentState is PianoListLoaded) {
      // Lọc theo category trước
      List<Piano> baseList = currentState.activeCategory == null || currentState.activeCategory!.isEmpty
          ? currentState.allPianos
          : currentState.allPianos.where((p) => p.category == currentState.activeCategory).toList();

      final filtered = _applySearch(baseList, event.query);

      emit(PianoListLoaded(
        pianos: filtered,
        allPianos: currentState.allPianos,
        categories: currentState.categories,
        activeCategory: currentState.activeCategory,
        searchQuery: event.query,
      ));
    }
  }

  List<Piano> _applySearch(List<Piano> pianos, String query) {
    if (query.isEmpty) return pianos;
    final lowerQuery = query.toLowerCase();
    return pianos.where((p) =>
      p.name.toLowerCase().contains(lowerQuery) ||
      p.category.toLowerCase().contains(lowerQuery) ||
      (p.description?.toLowerCase().contains(lowerQuery) ?? false)
    ).toList();
  }
}
