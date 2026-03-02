import 'package:sprint1_project/features/items/domain/entities/item_entity.dart';

class ItemApiModel {
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
  final int? preparationTime;
  final String? deliveryType;

  ItemApiModel({
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

  factory ItemApiModel.fromJson(Map<String, dynamic> json) {
    return ItemApiModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      discountPrice: json['discountPrice'] != null
          ? (json['discountPrice'] as num).toDouble()
          : null,
      category: json['category']?.toString(),
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isFeatured: json['isFeatured'] as bool? ?? false,
      isAvailable: json['isAvailable'] as bool? ?? true,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      numReviews: (json['numReviews'] as num?)?.toInt() ?? 0,
      preparationTime: (json['preparationTime'] as num?)?.toInt(),
      deliveryType: json['deliveryType']?.toString(),
    );
  }

  ItemEntity toEntity() => ItemEntity(
    id: id,
    name: name,
    slug: slug,
    description: description,
    price: price,
    discountPrice: discountPrice,
    category: category,
    images: images,
    isFeatured: isFeatured,
    isAvailable: isAvailable,
    stock: stock,
    rating: rating,
    numReviews: numReviews,
    preparationTime: preparationTime,
    deliveryType: deliveryType,
  );

  static List<ItemEntity> toEntityList(List<ItemApiModel> models) {
    return models.map((m) => m.toEntity()).toList();
  }
}
