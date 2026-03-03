import 'package:hive/hive.dart';
import 'package:sprint1_project/core/constants/hive_table_constants.dart';
import 'package:sprint1_project/features/favorites/domain/entities/favorite_entity.dart';
import 'package:sprint1_project/features/items/domain/entities/item_entity.dart';

part 'favorites_hive_model.g.dart';

// ── FavoriteItemHiveModel ─────────────────────────────────────────────────────

@HiveType(typeId: HiveTableConstant.favoritesTypeId)
class FavoriteItemHiveModel extends HiveObject {
  @HiveField(0)
  final String type;

  @HiveField(1)
  final String refId;

  // Flattened item fields (nullable — only present when type == 'product')
  @HiveField(2)
  final String? itemName;

  @HiveField(3)
  final double? itemPrice;

  @HiveField(4)
  final double? itemDiscountPrice;

  @HiveField(5)
  final List<String>? itemImages;

  @HiveField(6)
  final String? itemCategory;

  @HiveField(7)
  final int? itemStock;

  @HiveField(8)
  final bool? itemIsFeatured;

  @HiveField(9)
  final bool? itemIsAvailable;

  @HiveField(10)
  final String? itemSlug;

  @HiveField(11)
  final String? itemDescription;

  FavoriteItemHiveModel({
    required this.type,
    required this.refId,
    this.itemName,
    this.itemPrice,
    this.itemDiscountPrice,
    this.itemImages,
    this.itemCategory,
    this.itemStock,
    this.itemIsFeatured,
    this.itemIsAvailable,
    this.itemSlug,
    this.itemDescription,
  });

  /// Build from a [FavoriteEntity] (which may have a populated [refItem]).
  factory FavoriteItemHiveModel.fromEntity(FavoriteEntity entity) {
    final item = entity.refItem;
    return FavoriteItemHiveModel(
      type: entity.type,
      refId: entity.refId,
      itemName: item?.name,
      itemPrice: item?.price,
      itemDiscountPrice: item?.discountPrice,
      itemImages: item?.images,
      itemCategory: item?.category,
      itemStock: item?.stock,
      itemIsFeatured: item?.isFeatured,
      itemIsAvailable: item?.isAvailable,
      itemSlug: item?.slug,
      itemDescription: item?.description,
    );
  }

  FavoriteEntity toEntity() {
    ItemEntity? item;
    if (itemName != null && itemPrice != null) {
      item = ItemEntity(
        id: refId,
        name: itemName!,
        slug: itemSlug ?? '',
        description: itemDescription ?? '',
        price: itemPrice!,
        discountPrice: itemDiscountPrice,
        category: itemCategory,
        images: itemImages ?? [],
        isFeatured: itemIsFeatured ?? false,
        isAvailable: itemIsAvailable ?? true,
        stock: itemStock ?? 0,
        rating: 0,
        numReviews: 0,
      );
    }
    return FavoriteEntity(type: type, refId: refId, refItem: item);
  }
}
