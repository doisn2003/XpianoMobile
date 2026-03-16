import 'package:equatable/equatable.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object> get props => [];
}

class LoadFavorites extends FavoritesEvent {}

class RemoveFavorite extends FavoritesEvent {
  final int pianoId;

  const RemoveFavorite(this.pianoId);

  @override
  List<Object> get props => [pianoId];
}

