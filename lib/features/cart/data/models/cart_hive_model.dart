import 'package:hive/hive.dart';
import 'package:sprint1_project/core/constants/hive_table_constants.dart';
import 'package:sprint1_project/features/cart/domain/entities/cart_entity.dart';
import 'package:sprint1_project/features/items/domain/entities/item_entity.dart';

part 'cart_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.cartTypeId)
class CartItemHiveModel extends HiveObject {
  @HiveField(0)
  final String type;

  @HiveField(1)
  final String refId;

  @HiveField(2)
  final int quantity;

  @HiveField(3)
  final double unitPrice;

  @HiveField(4)
  final double subtotal;

  // Flattened item fields
  @HiveField(5)
  final String? itemName;

  @HiveField(6)
  final List<String>? itemImages;

  @HiveField(7)
  final String? itemCategory;

  @HiveField(8)
  final double? itemPrice;

  @HiveField(9)
  final double? itemDiscountPrice;

  @HiveField(10)
  final int? itemStock;

  @HiveField(11)
  final String? itemSlug;

  @HiveField(12)
  final String? itemDescription;

  @HiveField(13)
  final String? customRecipientName;

  CartItemHiveModel({
    required this.type,
    required this.refId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.itemName,
    this.itemImages,
    this.itemCategory,
    this.itemPrice,
    this.itemDiscountPrice,
    this.itemStock,
    this.itemSlug,
    this.itemDescription,
    this.customRecipientName,
  });

  factory CartItemHiveModel.fromEntity(CartItemEntity entity) {
    final item = entity.refItem;
    return CartItemHiveModel(
      type: entity.type,
      refId: entity.refId,
      quantity: entity.quantity,
      unitPrice: entity.unitPrice,
      subtotal: entity.subtotal,
      itemName: item?.name,
      itemImages: item?.images,
      itemCategory: item?.category,
      itemPrice: item?.price,
      itemDiscountPrice: item?.discountPrice,
      itemStock: item?.stock,
      itemSlug: item?.slug,
      itemDescription: item?.description,
      customRecipientName: entity.customDetails?['recipientName']?.toString(),
    );
  }

  CartItemEntity toEntity() {
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
        isFeatured: false,
        isAvailable: true,
        stock: itemStock ?? 0,
        rating: 0,
        numReviews: 0,
      );
    }
    return CartItemEntity(
      type: type,
      refId: refId,
      quantity: quantity,
      unitPrice: unitPrice,
      subtotal: subtotal,
      refItem: item,
      customDetails: customRecipientName != null
          ? {'recipientName': customRecipientName}
          : null,
    );
  }
}
