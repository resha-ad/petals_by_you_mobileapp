import 'package:equatable/equatable.dart';

enum DeliveryStatus {
  pending,
  assigned,
  inTransit,
  delivered,
  failed,
  cancelled;

  static DeliveryStatus fromString(String s) {
    switch (s) {
      case 'assigned':
        return DeliveryStatus.assigned;
      case 'in_transit':
        return DeliveryStatus.inTransit;
      case 'delivered':
        return DeliveryStatus.delivered;
      case 'failed':
        return DeliveryStatus.failed;
      case 'cancelled':
        return DeliveryStatus.cancelled;
      default:
        return DeliveryStatus.pending;
    }
  }

  String get displayLabel {
    switch (this) {
      case DeliveryStatus.pending:
        return 'Pending';
      case DeliveryStatus.assigned:
        return 'Assigned';
      case DeliveryStatus.inTransit:
        return 'Out for Delivery';
      case DeliveryStatus.delivered:
        return 'Delivered';
      case DeliveryStatus.failed:
        return 'Failed';
      case DeliveryStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class TrackingUpdateEntity extends Equatable {
  final String message;
  final DateTime timestamp;
  final String? updatedBy;

  const TrackingUpdateEntity({
    required this.message,
    required this.timestamp,
    this.updatedBy,
  });

  @override
  List<Object?> get props => [message, timestamp];
}

class DeliveryAddressEntity extends Equatable {
  final String street;
  final String city;
  final String? state;
  final String? zip;
  final String country;

  const DeliveryAddressEntity({
    required this.street,
    required this.city,
    this.state,
    this.zip,
    required this.country,
  });

  String get displayAddress {
    final parts = [
      street,
      city,
      if (state != null) state!,
      country,
    ].where((p) => p.isNotEmpty).toList();
    return parts.join(', ');
  }

  @override
  List<Object?> get props => [street, city, state, zip, country];
}

class DeliveryEntity extends Equatable {
  final String id;
  final String orderId;
  final String recipientName;
  final String recipientPhone;
  final DeliveryAddressEntity address;
  final DeliveryStatus status;
  final DateTime? scheduledDate;
  final DateTime? estimatedDelivery;
  final DateTime? deliveredAt;
  final List<TrackingUpdateEntity> trackingUpdates;
  final String? deliveryNotes;
  final String? cancelReason;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DeliveryEntity({
    required this.id,
    required this.orderId,
    required this.recipientName,
    required this.recipientPhone,
    required this.address,
    required this.status,
    this.scheduledDate,
    this.estimatedDelivery,
    this.deliveredAt,
    required this.trackingUpdates,
    this.deliveryNotes,
    this.cancelReason,
    this.cancelledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive =>
      status != DeliveryStatus.delivered &&
      status != DeliveryStatus.cancelled &&
      status != DeliveryStatus.failed;

  @override
  List<Object?> get props => [id, orderId, status];
}
