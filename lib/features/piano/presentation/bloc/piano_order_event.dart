import 'package:equatable/equatable.dart';

abstract class PianoOrderEvent extends Equatable {
  const PianoOrderEvent();
  @override
  List<Object?> get props => [];
}

class CreatePianoOrder extends PianoOrderEvent {
  final int pianoId;
  final String type; // 'buy' or 'rent'
  final String? rentalStartDate;
  final String? rentalEndDate;
  final String paymentMethod; // 'COD' or 'QR'

  const CreatePianoOrder({
    required this.pianoId,
    required this.type,
    this.rentalStartDate,
    this.rentalEndDate,
    this.paymentMethod = 'COD',
  });

  @override
  List<Object?> get props => [pianoId, type, rentalStartDate, rentalEndDate, paymentMethod];
}
