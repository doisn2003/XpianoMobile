import 'package:equatable/equatable.dart';

import '../../domain/entities/piano.dart';

abstract class PianoDetailState extends Equatable {
  const PianoDetailState();
  @override
  List<Object?> get props => [];
}

class PianoDetailInitial extends PianoDetailState {}

class PianoDetailLoading extends PianoDetailState {}

class PianoDetailLoaded extends PianoDetailState {
  final Piano piano;
  final bool isFavorited;

  const PianoDetailLoaded({required this.piano, this.isFavorited = false});

  PianoDetailLoaded copyWith({Piano? piano, bool? isFavorited}) {
    return PianoDetailLoaded(
      piano: piano ?? this.piano,
      isFavorited: isFavorited ?? this.isFavorited,
    );
  }

  @override
  List<Object?> get props => [piano, isFavorited];
}

class PianoDetailError extends PianoDetailState {
  final String message;
  const PianoDetailError(this.message);
  @override
  List<Object> get props => [message];
}
