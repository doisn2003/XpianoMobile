import 'package:equatable/equatable.dart';

abstract class PianoDetailEvent extends Equatable {
  const PianoDetailEvent();
  @override
  List<Object?> get props => [];
}

class LoadPianoDetail extends PianoDetailEvent {
  final int pianoId;
  const LoadPianoDetail(this.pianoId);
  @override
  List<Object> get props => [pianoId];
}

class TogglePianoFavorite extends PianoDetailEvent {
  final int pianoId;
  final bool currentlyFavorited;
  const TogglePianoFavorite(this.pianoId, this.currentlyFavorited);
  @override
  List<Object> get props => [pianoId, currentlyFavorited];
}
