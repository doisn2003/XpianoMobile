import 'package:equatable/equatable.dart';

class Piano extends Equatable {
  final int id;
  final String name;
  final String? imageUrl;
  final String category;
  final int pricePerDay;
  final int? price;
  final double rating;
  final int reviewsCount;
  final String? description;
  final List<String> features;

  const Piano({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.category,
    required this.pricePerDay,
    this.price,
    this.rating = 0,
    this.reviewsCount = 0,
    this.description,
    this.features = const [],
  });

  @override
  List<Object?> get props => [id, name, imageUrl, category, pricePerDay, price, rating, reviewsCount, description, features];
}
