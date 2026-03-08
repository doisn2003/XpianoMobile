import 'package:equatable/equatable.dart';

import '../../domain/entities/piano.dart';

abstract class PianoListState extends Equatable {
  const PianoListState();

  @override
  List<Object?> get props => [];
}

class PianoListInitial extends PianoListState {}

class PianoListLoading extends PianoListState {}

class PianoListLoaded extends PianoListState {
  final List<Piano> pianos;
  final List<Piano> allPianos; // Toàn bộ danh sách (dùng cho search/filter local)
  final List<String> categories;
  final String? activeCategory;
  final String searchQuery;

  const PianoListLoaded({
    required this.pianos,
    required this.allPianos,
    required this.categories,
    this.activeCategory,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [pianos, allPianos, categories, activeCategory, searchQuery];
}

class PianoListError extends PianoListState {
  final String message;

  const PianoListError(this.message);

  @override
  List<Object> get props => [message];
}
