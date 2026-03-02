import 'package:hive/hive.dart';
import 'package:sprint1_project/core/constants/hive_table_constants.dart';
import 'package:sprint1_project/features/items/domain/entities/item_entity.dart';

part 'item_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.itemTypeId)
class ItemHiveModel extends HiveObject {
  @HiveField(0)
  final String itemId;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String slug;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final double price;

  @HiveField(5)
  final double? discountPrice;

  @HiveField(6)
  final String? category;

  @HiveField(7)
  final List<String> images;

  @HiveField(8)
  final bool isFeatured;

  @HiveField(9)
  final bool isAvailable;

  @HiveField(10)
  final int stock;

  @HiveField(11)
  final int? preparationTime;

  @HiveField(12)
  final String? deliveryType;

  @HiveField(13)
  final DateTime cachedAt;

  ItemHiveModel({
    required this.itemId,
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
    this.preparationTime,
    this.deliveryType,
    DateTime? cachedAt,
  }) : cachedAt = cachedAt ?? DateTime.now();

  ItemEntity toEntity() {
    return ItemEntity(
      id: itemId,
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
      rating: 0,
      numReviews: 0,
      preparationTime: preparationTime,
      deliveryType: deliveryType,
    );
  }

  factory ItemHiveModel.fromEntity(ItemEntity entity) {
    return ItemHiveModel(
      itemId: entity.id,
      name: entity.name,
      slug: entity.slug,
      description: entity.description,
      price: entity.price,
      discountPrice: entity.discountPrice,
      category: entity.category,
      images: entity.images,
      isFeatured: entity.isFeatured,
      isAvailable: entity.isAvailable,
      stock: entity.stock,
      preparationTime: entity.preparationTime,
      deliveryType: entity.deliveryType,
    );
  }

  static List<ItemEntity> toEntityList(List<ItemHiveModel> models) {
    return models.map((m) => m.toEntity()).toList();
  }
}
