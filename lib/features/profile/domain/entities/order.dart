class OrderItem {
  final int id;
  final String? pianoId;
  final String? courseId;
  final String type; // 'buy', 'rent', 'course'
  final double totalPrice;
  final String? rentalStartDate;
  final String? rentalEndDate;
  final int? rentalDays;
  final String status;
  final String paymentMethod;
  final String? createdAt;
  final SimplePianoInfo? piano;

  const OrderItem({
    required this.id,
    this.pianoId,
    this.courseId,
    required this.type,
    required this.totalPrice,
    this.rentalStartDate,
    this.rentalEndDate,
    this.rentalDays,
    required this.status,
    required this.paymentMethod,
    this.createdAt,
    this.piano,
  });
}

class SimplePianoInfo {
  final String id;
  final String name;
  final String imageUrl;
  final String category;
  final String? description;
  final int reviewsCount;
  final int? pricePerDay;

  const SimplePianoInfo({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.category,
    this.description,
    this.reviewsCount = 0,
    this.pricePerDay,
  });

  @override
  List<Object?> get props => [id, name, imageUrl, category, description, reviewsCount, pricePerDay];
}
