import 'package:sprint1_project/features/cart/domain/entities/cart_entity.dart';
import 'package:sprint1_project/features/items/data/models/item_api_model.dart';

class CartItemApiModel {
  final String type;
  final String refId;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final ItemApiModel? refItem; // populated from refDetails
  final Map<String, dynamic>? customDetails;

  const CartItemApiModel({
    required this.type,
    required this.refId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.refItem,
    this.customDetails,
  });

  factory CartItemApiModel.fromJson(Map<String, dynamic> json) {
    // refId may be plain string or populated object
    final rawRef = json['refId'];
    String id;
    ItemApiModel? item;
    Map<String, dynamic>? customDetails;

    if (rawRef is Map<String, dynamic>) {
      id = rawRef['_id']?.toString() ?? '';
    } else {
      id = rawRef?.toString() ?? '';
    }

    // refDetails is the enriched product/custom data added by the backend repo
    final details = json['refDetails'];
    final type = json['type']?.toString() ?? 'product';
    if (details is Map<String, dynamic>) {
      if (type == 'product') {
        // Merge _id into details so ItemApiModel can parse it
        item = ItemApiModel.fromJson({...details, '_id': id});
      } else {
        customDetails = Map<String, dynamic>.from(details);
      }
    }

    return CartItemApiModel(
      type: type,
      refId: id,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      refItem: item,
      customDetails: customDetails,
    );
  }

  CartItemEntity toEntity() => CartItemEntity(
    type: type,
    refId: refId,
    quantity: quantity,
    unitPrice: unitPrice,
    subtotal: subtotal,
    refItem: refItem?.toEntity(),
    customDetails: customDetails,
  );
}

class CartApiModel {
  final String userId;
  final List<CartItemApiModel> items;
  final double total;

  const CartApiModel({
    required this.userId,
    required this.items,
    required this.total,
  });

  factory CartApiModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return CartApiModel(
      userId: json['userId']?.toString() ?? '',
      items: rawItems
          .map((e) => CartItemApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toDouble() ?? 0,
    );
  }

  CartEntity toEntity() => CartEntity(
    userId: userId,
    items: items.map((i) => i.toEntity()).toList(),
    total: total,
  );
}
