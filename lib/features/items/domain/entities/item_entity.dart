import 'package:equatable/equatable.dart';

class ItemEntity extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String description;
  final double price;
  final double? discountPrice;
  final String? category;
  final List<String> images;
  final bool isFeatured;
  final bool isAvailable;
  final int stock;
  final double rating;
  final int numReviews;
  final int? preparationTime; // in minutes
  final String? deliveryType;

  const ItemEntity({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    this.discountPrice,
    this.category,
    required this.images,
    required this.isFeatured,
    required this.isAvailable,
    required this.stock,
    required this.rating,
    required this.numReviews,
    this.preparationTime,
    this.deliveryType,
  });

  /// Effective price — discountPrice if available, otherwise price
  double get effectivePrice => discountPrice ?? price;

  /// True if item has an active discount
  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  /// First image url or null
  String? get primaryImage => images.isNotEmpty ? images.first : null;

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    price,
    discountPrice,
    category,
    images,
    isFeatured,
    isAvailable,
    stock,
    rating,
  ];
}
