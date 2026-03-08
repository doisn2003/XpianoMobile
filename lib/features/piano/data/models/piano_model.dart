import '../../domain/entities/piano.dart';

class PianoModel extends Piano {
  const PianoModel({
    required super.id,
    required super.name,
    super.imageUrl,
    required super.category,
    required super.pricePerDay,
    super.price,
    super.rating,
    super.reviewsCount,
    super.description,
    super.features,
  });

  /// Xử lý dual JSON: Supabase trả snake_case, Express có thể trả camelCase
  factory PianoModel.fromJson(Map<String, dynamic> json) {
    // Parse features — có thể là List<String> hoặc String JSON
    List<String> features = [];
    final rawFeatures = json['features'];
    if (rawFeatures is List) {
      features = rawFeatures.map((e) => e.toString()).toList();
    }

    return PianoModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'],
      category: json['category'] ?? '',
      pricePerDay: _parseInt(json['price_per_day'] ?? json['pricePerDay'] ?? 0),
      price: json['price'] != null ? _parseInt(json['price']) : null,
      rating: _parseDouble(json['rating'] ?? 0),
      reviewsCount: _parseInt(json['reviews_count'] ?? json['reviewsCount'] ?? 0),
      description: json['description'],
      features: features,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'category': category,
      'price_per_day': pricePerDay,
      'price': price,
      'rating': rating,
      'reviews_count': reviewsCount,
      'description': description,
      'features': features,
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}
