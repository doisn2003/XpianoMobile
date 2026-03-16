import '../../domain/entities/active_rental.dart';
import 'order_model.dart'; // To reuse SimplePianoInfoModel

class ActiveRentalModel extends ActiveRental {
  const ActiveRentalModel({
    required super.id,
    required super.userId,
    required super.pianoId,
    required super.startDate,
    required super.endDate,
    required super.totalPrice,
    required super.status,
    super.piano,
  });

  factory ActiveRentalModel.fromJson(Map<String, dynamic> json) {
    return ActiveRentalModel(
      id: json['id'] as int,
      userId: json['user_id']?.toString() ?? '',
      pianoId: json['piano_id']?.toString() ?? '',
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String? ?? '',
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'active',
      piano: json['piano'] != null ? SimplePianoInfoModel.fromJson(json['piano']) : null,
    );
  }
}
