import '../../domain/entities/order.dart';

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.id,
    super.pianoId,
    super.courseId,
    required super.type,
    required super.totalPrice,
    super.rentalStartDate,
    super.rentalEndDate,
    super.rentalDays,
    required super.status,
    required super.paymentMethod,
    super.createdAt,
    super.piano,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int,
      pianoId: json['piano_id']?.toString(),
      courseId: json['course_id']?.toString(),
      type: json['type'] as String? ?? 'buy',
      totalPrice: (json['total_price'] as num).toDouble(),
      rentalStartDate: json['rental_start_date'] as String?,
      rentalEndDate: json['rental_end_date'] as String?,
      rentalDays: json['rental_days'] as int?,
      status: json['status'] as String? ?? 'pending',
      paymentMethod: json['payment_method'] as String? ?? 'COD',
      createdAt: json['created_at'] as String?,
      piano: json['piano'] != null ? SimplePianoInfoModel.fromJson(json['piano']) : null,
    );
  }
}

class SimplePianoInfoModel extends SimplePianoInfo {
  const SimplePianoInfoModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    required super.category,
    super.description,
    super.reviewsCount = 0,
    super.pricePerDay,
  });

  factory SimplePianoInfoModel.fromJson(Map<String, dynamic> json) {
    return SimplePianoInfoModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      category: json['category'] as String? ?? '',
      description: json['description'] as String?,
      reviewsCount: json['reviews_count'] as int? ?? 0,
      pricePerDay: json['price_per_day'] as int?,
    );
  }
}
