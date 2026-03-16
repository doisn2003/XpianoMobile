import 'order.dart';

class ActiveRental {
  final int id;
  final String userId;
  final String pianoId;
  final String startDate;
  final String endDate;
  final double totalPrice;
  final String status; // usually 'active'
  final SimplePianoInfo? piano;

  const ActiveRental({
    required this.id,
    required this.userId,
    required this.pianoId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    this.piano,
  });
}
