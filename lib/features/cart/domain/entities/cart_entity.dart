import 'package:equatable/equatable.dart';
import 'package:sprint1_project/features/items/domain/entities/item_entity.dart';

class CartItemEntity extends Equatable {
  final String type; // "product" | "custom"
  final String refId;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  // Populated product details (null for custom)
  final ItemEntity? refItem;
  // For custom bouquets a lightweight details map
  final Map<String, dynamic>? customDetails;

  const CartItemEntity({
    required this.type,
    required this.refId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.refItem,
    this.customDetails,
  });

  String get displayName {
    if (refItem != null) return refItem!.name;
    if (customDetails != null) {
      final recipient = customDetails!['recipientName']?.toString() ?? '';
      final flowers = customDetails!['flowers'] as List?;
      final names =
          flowers
              ?.take(2)
              .map((f) => f['name']?.toString() ?? '')
              .where((n) => n.isNotEmpty)
              .join(' & ') ??
          '';
      if (recipient.isNotEmpty) return 'Custom Bouquet for $recipient';
      if (names.isNotEmpty) return 'Custom Bouquet ($names)';
    }
    return 'Custom Bouquet';
  }

  // Additional helper for cart display
  String get customDescription {
    if (type != 'custom' || customDetails == null) return '';
    final flowers = customDetails!['flowers'] as List?;
    final wrapping = customDetails!['wrapping'] as Map?;
    final parts = <String>[];
    if (flowers != null && flowers.isNotEmpty) {
      final stems = flowers.fold<int>(
        0,
        (sum, f) => sum + ((f['count'] as num?)?.toInt() ?? 0),
      );
      parts.add('$stems stems');
    }
    if (wrapping != null) parts.add(wrapping['name']?.toString() ?? '');
    return parts.join(' · ');
  }

  String? get displayImage => refItem?.primaryImage;

  @override
  List<Object?> get props => [type, refId, quantity, unitPrice, subtotal];
}

class CartEntity extends Equatable {
  final String userId;
  final List<CartItemEntity> items;
  final double total;

  const CartEntity({
    required this.userId,
    required this.items,
    required this.total,
  });

  bool get isEmpty => items.isEmpty;
  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  @override
  List<Object?> get props => [userId, items, total];
}
