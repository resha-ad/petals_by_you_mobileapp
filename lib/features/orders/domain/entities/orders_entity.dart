import 'package:equatable/equatable.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  outForDelivery,
  delivered,
  cancelled;

  static OrderStatus fromString(String s) {
    switch (s) {
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'out_for_delivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  String get displayLabel {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class OrderItemEntity extends Equatable {
  final String type;
  final String refId;
  final String name;
  final double unitPrice;
  final int quantity;
  final double subtotal;
  final String? imageUrl;

  const OrderItemEntity({
    required this.type,
    required this.refId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [type, refId, quantity];
}

class OrderEntity extends Equatable {
  final String id;
  final List<OrderItemEntity> items;
  final double totalAmount;
  final OrderStatus status;
  final String paymentStatus;
  final String paymentMethod;
  final String? notes;
  final String? cancelReason;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderEntity({
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

  bool get isCancellable => status == OrderStatus.pending;
  bool get isActive =>
      status != OrderStatus.delivered && status != OrderStatus.cancelled;

  @override
  List<Object?> get props => [id, status, totalAmount];
}
