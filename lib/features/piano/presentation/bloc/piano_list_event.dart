import 'package:equatable/equatable.dart';

abstract class PianoListEvent extends Equatable {
  const PianoListEvent();

  @override
  List<Object?> get props => [];
}

class LoadPianos extends PianoListEvent {}

class FilterByCategory extends PianoListEvent {
  final String? category;

  const FilterByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class SearchPianos extends PianoListEvent {
  final String query;

  const SearchPianos(this.query);

  @override
  List<Object> get props => [query];
}
