import 'package:sprint1_project/features/orders/domain/entities/orders_entity.dart';

class OrderItemApiModel {
  final String type;
  final String refId;
  final String name;
  final double unitPrice;
  final int quantity;
  final double subtotal;
  final String? imageUrl;

  const OrderItemApiModel({
    required this.type,
    required this.refId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
    this.imageUrl,
  });

  factory OrderItemApiModel.fromJson(Map<String, dynamic> json) {
    return OrderItemApiModel(
      type: json['type']?.toString() ?? 'product',
      refId: json['refId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      imageUrl: json['imageUrl']?.toString(),
    );
  }

  OrderItemEntity toEntity() => OrderItemEntity(
    type: type,
    refId: refId,
    name: name,
    unitPrice: unitPrice,
    quantity: quantity,
    subtotal: subtotal,
    imageUrl: imageUrl,
  );
}

class OrderApiModel {
  final String id;
  final List<OrderItemApiModel> items;
  final double totalAmount;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final String? notes;
  final String? cancelReason;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderApiModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    this.notes,
    this.cancelReason,
    this.cancelledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderApiModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return OrderApiModel(
      id: json['_id']?.toString() ?? '',
      items: rawItems
          .map((e) => OrderItemApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      status: json['status']?.toString() ?? 'pending',
      paymentStatus: json['paymentStatus']?.toString() ?? 'unpaid',
      paymentMethod: json['paymentMethod']?.toString() ?? 'cash_on_delivery',
      notes: json['notes']?.toString(),
      cancelReason: json['cancelReason']?.toString(),
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.tryParse(json['cancelledAt'].toString())
          : null,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  OrderEntity toEntity() => OrderEntity(
    id: id,
    items: items.map((i) => i.toEntity()).toList(),
    totalAmount: totalAmount,
    status: OrderStatus.fromString(status),
    paymentStatus: paymentStatus,
    paymentMethod: paymentMethod,
    notes: notes,
    cancelReason: cancelReason,
    cancelledAt: cancelledAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
